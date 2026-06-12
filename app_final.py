from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify, send_from_directory
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os
import pymysql
from werkzeug.utils import secure_filename
from PIL import Image
import io
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

# Ensure upload folder exists with absolute path
upload_folder = os.path.abspath(app.config['UPLOAD_FOLDER'])
app.config['UPLOAD_FOLDER'] = upload_folder
os.makedirs(upload_folder, exist_ok=True)
print(f"Upload folder: {upload_folder}")  # Debug line

# Initialize database tables if they don't exist
def init_db():
    connection = pymysql.connect(
        host=app.config['MYSQL_HOST'],
        user=app.config['MYSQL_USER'],
        password=app.config['MYSQL_PASSWORD'],
        database=app.config['MYSQL_DB'],
        autocommit=True
    )
    try:
        with connection.cursor() as cursor:
            # Create contact_queries table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS contact_queries (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    email VARCHAR(255) NOT NULL,
                    subject VARCHAR(255),
                    message TEXT NOT NULL,
                    status ENUM('Pending', 'Resolved') DEFAULT 'Pending',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """)

            # Create user_follows table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS user_follows (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    follower_id INT NOT NULL,
                    followed_id INT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (follower_id) REFERENCES users(id) ON DELETE CASCADE,
                    FOREIGN KEY (followed_id) REFERENCES users(id) ON DELETE CASCADE,
                    UNIQUE KEY unique_follow (follower_id, followed_id)
                )
            """)
            # Ensure recipes table has views and video_url columns
            try:
                cursor.execute("SELECT views FROM recipes LIMIT 1")
            except:
                cursor.execute("ALTER TABLE recipes ADD COLUMN views INT DEFAULT 0")
            
            try:
                cursor.execute("SELECT video_url FROM recipes LIMIT 1")
            except:
                cursor.execute("ALTER TABLE recipes ADD COLUMN video_url VARCHAR(512)")
                # One-time migration for Khaman recipe
                cursor.execute("""
                    UPDATE recipes 
                    SET video_url = 'https://youtu.be/w_2eb9uaXns?si=gHfWPbPFBloqoXVB' 
                    WHERE title LIKE '%Khaman%' AND (video_url IS NULL OR video_url = '')
                """)

            # Ensure recipe_ratings table has reply columns
            try:
                cursor.execute("SELECT author_reply FROM recipe_ratings LIMIT 1")
            except:
                cursor.execute("ALTER TABLE recipe_ratings ADD COLUMN author_reply TEXT")
                cursor.execute("ALTER TABLE recipe_ratings ADD COLUMN replied_at TIMESTAMP NULL")
            
            print("Database tables initialized successfully.")
    except Exception as e:
        print(f"Error initializing database tables: {e}")
    finally:
        connection.close()

init_db()

# Database connection function
def get_db_connection():
    try:
        connection = pymysql.connect(
            host=app.config['MYSQL_HOST'],
            user=app.config['MYSQL_USER'],
            password=app.config['MYSQL_PASSWORD'],
            database=app.config['MYSQL_DB'],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True
        )
        return connection
    except Exception as e:
        print(f"Database connection error: {e}")
        return None

# Template filter for newlines
@app.template_filter('nl2br')
def nl2br_filter(text):
    """Convert newlines to <br> tags"""
    if text is None:
        return ''
    from markupsafe import Markup
    return Markup(text.replace('\n', '<br>\n'))

# Helper function to check if file is allowed
def allowed_file(filename):
    if not filename:
        print("Filename is empty")  # Debug line
        return False
    if '.' not in filename:
        print(f"No dot in filename: {filename}")  # Debug line
        return False
    ext = filename.rsplit('.', 1)[1].lower()
    allowed = ext in app.config['ALLOWED_EXTENSIONS']
    print(f"File extension: {ext}, Allowed: {allowed}")  # Debug line
    return allowed

# ── Chef Badge / Achievement System ──────────────────────────────────────────
BADGE_DEFINITIONS = [
    {
        'id': 'first_recipe',
        'name': 'First Recipe',
        'description': 'Uploaded their very first recipe',
        'emoji': '🥉',
        'color': '#cd7f32',
        'gradient': 'linear-gradient(135deg, #cd7f32, #a05c1a)',
    },
    {
        'id': 'top_chef',
        'name': 'Top Chef',
        'description': 'Average rating above 4.5 with 5+ ratings',
        'emoji': '⭐',
        'color': '#f5a623',
        'gradient': 'linear-gradient(135deg, #f5a623, #c9860f)',
    },
    {
        'id': 'fan_favorite',
        'name': 'Fan Favorite',
        'description': 'Has a recipe with 10 or more favorites',
        'emoji': '🔥',
        'color': '#e74c3c',
        'gradient': 'linear-gradient(135deg, #e74c3c, #c0392b)',
    },
    {
        'id': 'prolific_chef',
        'name': 'Prolific Chef',
        'description': 'Uploaded 5 or more recipes',
        'emoji': '📚',
        'color': '#8e44ad',
        'gradient': 'linear-gradient(135deg, #8e44ad, #6c3483)',
    },
    {
        'id': 'crowd_pleaser',
        'name': 'Crowd Pleaser',
        'description': 'Received 20 or more total ratings',
        'emoji': '🎉',
        'color': '#27ae60',
        'gradient': 'linear-gradient(135deg, #27ae60, #1e8449)',
    },
]

def get_user_badges(cursor, user_id):
    """Return earned badge dicts for a user based on their stats."""
    # Recipe count
    cursor.execute("SELECT COUNT(*) as cnt FROM recipes WHERE user_id = %s", (user_id,))
    recipe_count = cursor.fetchone()['cnt']

    # Avg rating + total ratings across all user recipes
    cursor.execute("""
        SELECT AVG(rr.rating) as avg_r, COUNT(rr.id) as total_r
        FROM recipes r
        JOIN recipe_ratings rr ON r.id = rr.recipe_id
        WHERE r.user_id = %s
    """, (user_id,))
    row = cursor.fetchone()
    avg_rating    = float(row['avg_r'])  if row['avg_r']    else 0.0
    total_ratings = int(row['total_r'])  if row['total_r']  else 0

    # Max favorites on any single recipe by this user
    cursor.execute("""
        SELECT MAX(fav_count) as max_favs FROM (
            SELECT COUNT(*) as fav_count
            FROM recipe_favorites rf
            JOIN recipes r ON rf.recipe_id = r.id
            WHERE r.user_id = %s
            GROUP BY rf.recipe_id
        ) sub
    """, (user_id,))
    fav_row  = cursor.fetchone()
    max_favs = int(fav_row['max_favs']) if fav_row and fav_row['max_favs'] else 0

    checks = {
        'first_recipe':  recipe_count >= 1,
        'top_chef':      avg_rating > 4.5 and total_ratings >= 5,
        'fan_favorite':  max_favs >= 10,
        'prolific_chef': recipe_count >= 5,
        'crowd_pleaser': total_ratings >= 20,
    }
    return [b for b in BADGE_DEFINITIONS if checks.get(b['id'])]
# ─────────────────────────────────────────────────────────────────────────────

# Helper function to process and save image with quality
def process_and_save_image(file, filename, upload_folder):
    """Process image to maintain quality and proper sizing"""
    try:
        # Open the image
        image = Image.open(file.stream)
        
        # Convert RGBA to RGB if necessary
        if image.mode in ('RGBA', 'LA', 'P'):
            background = Image.new('RGB', image.size, (255, 255, 255))
            if image.mode == 'P':
                image = image.convert('RGBA')
            background.paste(image, mask=image.split()[-1] if image.mode == 'RGBA' else None)
            image = background
        
        # Calculate optimal size (maintain aspect ratio, max width 1920px)
        max_width = 1920
        max_height = 1440
        
        # Get current dimensions
        width, height = image.size
        
        # Calculate new dimensions
        if width > max_width or height > max_height:
            ratio = min(max_width / width, max_height / height)
            new_width = int(width * ratio)
            new_height = int(height * ratio)
            image = image.resize((new_width, new_height), Image.Resampling.LANCZOS)
            print(f"Resized image from {width}x{height} to {new_width}x{new_height}")
        
        # Save with high quality
        filepath = os.path.join(upload_folder, filename)
        
        # Determine format based on extension
        ext = os.path.splitext(filename)[1].lower()
        if ext in ['.jpg', '.jpeg']:
            image.save(filepath, 'JPEG', quality=100, optimize=True, subsampling=0)
        elif ext == '.png':
            image.save(filepath, 'PNG', optimize=True)
        elif ext == '.webp':
            image.save(filepath, 'WEBP', quality=100, optimize=True)
        else:
            # Default to JPEG for other formats
            image.save(filepath, 'JPEG', quality=100, optimize=True, subsampling=0)
        
        print(f"Image processed and saved: {filepath}")
        return True
        
    except Exception as e:
        print(f"Error processing image: {e}")
        # Fallback to save original file
        filepath = os.path.join(upload_folder, filename)
        file.save(filepath)
        return False

# Route to serve uploaded files
@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'], filename)

# Test route for debugging uploads
@app.route('/test-upload')
def test_upload():
    return '''
    <form action="/create" method="post" enctype="multipart/form-data">
        <input type="text" name="title" value="Test Recipe" required><br>
        <input type="text" name="ingredients" value="Test ingredients" required><br>
        <input type="text" name="instructions" value="Test instructions" required><br>
        <input type="file" name="image"><br>
        <button type="submit">Upload</button>
    </form>
    '''

# Home page - Display all recipes
@app.route('/')
def index():
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return render_template('index.html', recipes=[], categories=[])
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT r.*, u.username, c.name as category_name,
                       IFNULL(AVG(rr.rating), 0) as avg_rating,
                       COUNT(rr.id) as rating_count
                FROM recipes r
                JOIN users u ON r.user_id = u.id
                LEFT JOIN categories c ON r.category_id = c.id
                LEFT JOIN recipe_ratings rr ON r.id = rr.recipe_id
                GROUP BY r.id
                ORDER BY r.created_at DESC
                LIMIT 8
            """)
            recipes = cursor.fetchall()
            
            # New: Get total recipe count for stats section
            cursor.execute("SELECT COUNT(*) as total_count FROM recipes")
            total_recipes_count = cursor.fetchone()['total_count']

            
            cursor.execute("SELECT * FROM categories ORDER BY name")
            categories = cursor.fetchall()

            # Get favorite recipe IDs for current user
            user_favorites = []
            if 'user_id' in session:
                cursor.execute("SELECT recipe_id FROM recipe_favorites WHERE user_id = %s", (session['user_id'],))
                user_favorites = [f['recipe_id'] for f in cursor.fetchall()]
            
            # Calculate global stats
            cursor.execute("SELECT AVG(rating) as global_avg FROM recipe_ratings")
            global_avg_rating = cursor.fetchone()['global_avg'] or 0
            
            cursor.execute("SELECT COUNT(*) as total_favs FROM recipe_favorites")
            total_favorites = cursor.fetchone()['total_favs'] or 0
    finally:
        connection.close()
    
    return render_template('index.html', 
                         recipes=recipes, 
                         categories=categories, 
                         user_favorites=user_favorites,
                         global_avg_rating=global_avg_rating,
                         total_favorites=total_favorites,
                         total_recipes_count=total_recipes_count)


# User registration
@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']
        first_name = request.form.get('first_name', '')
        last_name = request.form.get('last_name', '')
        
        connection = get_db_connection()
        if not connection:
            flash('Database connection error!', 'danger')
            return redirect(url_for('register'))
        
        try:
            with connection.cursor() as cursor:
                # Check if user already exists
                cursor.execute("SELECT id FROM users WHERE username = %s OR email = %s", (username, email))
                if cursor.fetchone():
                    flash('Username or email already exists!', 'danger')
                    return redirect(url_for('register'))
                
                # Create new user
                password_hash = generate_password_hash(password)
                cursor.execute("""
                    INSERT INTO users (username, email, password_hash, first_name, last_name)
                    VALUES (%s, %s, %s, %s, %s)
                """, (username, email, password_hash, first_name, last_name))
                connection.commit()
                
            flash('Registration successful! Please login.', 'success')
            return redirect(url_for('login'))
        finally:
            connection.close()
    
    return render_template('register.html')

# User login
@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        connection = get_db_connection()
        if not connection:
            flash('Database connection error!', 'danger')
            return redirect(url_for('login'))
        
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
                user = cursor.fetchone()
                
                if user and check_password_hash(user['password_hash'], password):
                    session['user_id'] = user['id']
                    session['username'] = user['username']
                    session['profile_image'] = user['profile_image']
                    flash('Login successful!', 'success')
                    return redirect(url_for('index'))
                else:
                    flash('Invalid username or password!', 'danger')
        finally:
            connection.close()
    
    return render_template('login.html')

# User logout
@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out!', 'info')
    return redirect(url_for('index'))

# Create new recipe
@app.route('/recipe/create', methods=['GET', 'POST'])
def create_recipe():
    if 'user_id' not in session:
        flash('Please login to create a recipe!', 'danger')
        return redirect(url_for('login'))
    
    if request.method == 'POST':
        title = request.form['title']
        description = request.form.get('description', '')
        ingredients = request.form['ingredients']
        instructions = request.form['instructions']
        prep_time = request.form.get('prep_time', 0) or 0
        cook_time = request.form.get('cook_time', 0) or 0
        servings = request.form.get('servings', 1) or 1
        difficulty = request.form.get('difficulty', 'Medium')
        category_id = request.form.get('category_id') or None
        video_url = request.form.get('video_url', '').strip()
        
        # Handle image upload
        image_url = ''
        if 'image' in request.files:
            file = request.files['image']
            print(f"File received: {file.filename}")  # Debug line
            print(f"File content type: {file.content_type}")  # Debug line
            
            if file and file.filename != '' and allowed_file(file.filename):
                # Get file extension
                filename = secure_filename(file.filename)
                name, ext = os.path.splitext(filename)
                
                # Convert .jfif to .jpg for better compatibility
                if ext.lower() == '.jfif':
                    ext = '.jpg'
                    print(f"Converting .jfif to .jpg")  # Debug line
                
                # Create new filename with timestamp
                new_filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{name}{ext}"
                
                # Process and save image with quality optimization
                success = process_and_save_image(file, new_filename, app.config['UPLOAD_FOLDER'])
                
                if success:
                    print(f"Image processed successfully: {new_filename}")
                else:
                    print(f"Image saved without processing: {new_filename}")
                
                image_url = new_filename
            else:
                print(f"File not allowed or empty: {file.filename}")  # Debug line
                print(f"Allowed extensions: {app.config['ALLOWED_EXTENSIONS']}")  # Debug line
        else:
            print("No image in request.files")  # Debug line
        
        connection = get_db_connection()
        if not connection:
            flash('Database connection error!', 'danger')
            return redirect(url_for('create_recipe'))
        
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO recipes (title, description, ingredients, instructions, 
                                       prep_time, cook_time, servings, difficulty, 
                                       image_url, user_id, category_id, video_url)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (title, description, ingredients, instructions, int(prep_time), 
                      int(cook_time), int(servings), difficulty, image_url, session['user_id'], category_id, video_url))
                connection.commit()
            
            flash('Recipe created successfully!', 'success')
            return redirect(url_for('index'))
        finally:
            connection.close()
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('index'))
    
    try:
        with connection.cursor() as cursor:
            # Fetch stats for sidebar
            cursor.execute("SELECT COUNT(*) as count FROM recipes")
            recipe_count = cursor.fetchone()['count']
            cursor.execute("SELECT COUNT(*) as count FROM users")
            user_count = cursor.fetchone()['count']
            
            cursor.execute("SELECT * FROM categories ORDER BY name")
            categories = cursor.fetchall()
        return render_template('create_recipe.html', categories=categories, recipe_count=recipe_count, user_count=user_count)
    finally:
        connection.close()

# View recipe details
@app.route('/recipe/<int:recipe_id>')
def view_recipe(recipe_id):
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('index'))
    
    try:
        with connection.cursor() as cursor:
            # Increment view count
            cursor.execute("UPDATE recipes SET views = views + 1 WHERE id = %s", (recipe_id,))
            
            cursor.execute("""
                SELECT r.*, u.username, u.first_name, u.last_name, u.bio, u.profile_image as author_image,
                       c.name as category_name,
                       AVG(rr_all.rating) as avg_rating,
                       COUNT(rr_all.id) as rating_count
                FROM recipes r
                JOIN users u ON r.user_id = u.id
                LEFT JOIN categories c ON r.category_id = c.id
                LEFT JOIN recipe_ratings rr_all ON r.id = rr_all.recipe_id
                WHERE r.id = %s
                GROUP BY r.id
            """, (recipe_id,))
            recipe = cursor.fetchone()
            
            if not recipe:
                flash('Recipe not found!', 'danger')
                return redirect(url_for('index'))

            # Check if current user follows author
            is_following = False
            if 'user_id' in session:
                cursor.execute("SELECT id FROM user_follows WHERE follower_id = %s AND followed_id = %s", 
                             (session['user_id'], recipe['user_id']))
                if cursor.fetchone():
                    is_following = True
            
            # Get ratings for this recipe
            cursor.execute("""
                SELECT rr.*, u.username
                FROM recipe_ratings rr
                JOIN users u ON rr.user_id = u.id
                WHERE rr.recipe_id = %s
                ORDER BY rr.created_at DESC
            """, (recipe_id,))
            ratings = cursor.fetchall()
            
            # Check if current user has rated this recipe
            user_rating = None
            if 'user_id' in session:
                cursor.execute("""
                    SELECT * FROM recipe_ratings 
                    WHERE recipe_id = %s AND user_id = %s
                """, (recipe_id, session['user_id']))
                user_rating = cursor.fetchone()
            
            # Check if recipe is favorited by current user
            is_favorited = False
            if 'user_id' in session:
                cursor.execute("""
                    SELECT * FROM recipe_favorites 
                    WHERE recipe_id = %s AND user_id = %s
                """, (recipe_id, session['user_id']))
                is_favorited = cursor.fetchone() is not None
            
            # Fetch related recipes (same category, different ID)
            related_recipes = []
            if recipe['category_id']:
                cursor.execute("""
                    SELECT r.*, u.username,
                           IFNULL(AVG(rr.rating), 0) as avg_rating,
                           COUNT(rr.id) as rating_count
                    FROM recipes r
                    JOIN users u ON r.user_id = u.id
                    LEFT JOIN recipe_ratings rr ON r.id = rr.recipe_id
                    WHERE r.category_id = %s AND r.id != %s
                    GROUP BY r.id
                    LIMIT 3
                """, (recipe['category_id'], recipe_id))
                related_recipes = cursor.fetchall()
        
        return render_template('view_recipe.html', recipe=recipe, reviews=ratings, 
                             user_rating=user_rating, is_favorited=is_favorited,
                             related_recipes=related_recipes, is_following=is_following)
    finally:
        connection.close()

# Rate recipe
@app.route('/recipe/<int:recipe_id>/rate', methods=['POST'])
def rate_recipe(recipe_id):
    if 'user_id' not in session:
        flash('Please login to rate recipes!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    rating = request.form.get('rating')
    review = request.form.get('review', '')
    
    if not rating:
        flash('Please select a rating!', 'warning')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))

    try:
        rating_int = int(rating)
        if not (1 <= rating_int <= 5):
            flash('Invalid rating value!', 'danger')
            return redirect(url_for('view_recipe', recipe_id=recipe_id))
    except (ValueError, TypeError):
        flash('Invalid rating!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO recipe_ratings (recipe_id, user_id, rating, review)
                VALUES (%s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE rating = %s, review = %s
            """, (recipe_id, session['user_id'], rating_int, review, rating_int, review))
            connection.commit()
        
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return jsonify({'success': True, 'message': 'Thank you for your rating!'})
            
        flash('Thank you for your rating!', 'success')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    finally:
        connection.close()

# Remove rating
@app.route('/recipe/<int:recipe_id>/remove-rating', methods=['POST'])
def remove_rating(recipe_id):
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Login required'}), 401
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'message': 'Database connection error'}), 500
        
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                DELETE FROM recipe_ratings 
                WHERE recipe_id = %s AND user_id = %s
            """, (recipe_id, session['user_id']))
            connection.commit()
            
            return jsonify({'success': True, 'message': 'Rating removed successfully'})
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500
    finally:
        connection.close()


# Add review
@app.route('/recipe/<int:recipe_id>/review', methods=['POST'], endpoint='add_review')
def add_review(recipe_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    comment = request.form.get('comment', '').strip()
    
    if not comment:
        flash('Please enter a review comment!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    try:
        with connection.cursor() as cursor:
            # Check if user already rated this recipe
            cursor.execute("""
                SELECT id FROM recipe_ratings 
                WHERE recipe_id = %s AND user_id = %s
            """, (recipe_id, session['user_id']))
            
            existing_rating = cursor.fetchone()
            
            if existing_rating:
                # Update existing rating with review
                cursor.execute("""
                    UPDATE recipe_ratings 
                    SET review = %s 
                    WHERE recipe_id = %s AND user_id = %s
                """, (comment, recipe_id, session['user_id']))
            else:
                # Insert new review with default rating
                cursor.execute("""
                    INSERT INTO recipe_ratings (recipe_id, user_id, rating, review)
                    VALUES (%s, %s, %s, %s)
                """, (recipe_id, session['user_id'], 5, comment))
            
            connection.commit()
        
        flash('Review added successfully!', 'success')
    except Exception as e:
        print(f"Error adding review: {e}")
        flash('Error adding review!', 'danger')
    finally:
        connection.close()
    
    return redirect(url_for('view_recipe', recipe_id=recipe_id))

# Author reply to review
@app.route('/recipe/review/<int:review_id>/reply', methods=['POST'])
def author_reply_review(review_id):
    if 'user_id' not in session:
        flash('Please login to reply!', 'danger')
        return redirect(url_for('login'))
    
    reply_content = request.form.get('reply_content', '').strip()
    if not reply_content:
        flash('Reply content cannot be empty!', 'warning')
        return redirect(request.referrer or url_for('index'))
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(request.referrer or url_for('index'))
    
    try:
        with connection.cursor() as cursor:
            # Verify the logged-in user is the author of the recipe
            cursor.execute("""
                SELECT r.user_id, r.id as recipe_id
                FROM recipe_ratings rr
                JOIN recipes r ON rr.recipe_id = r.id
                WHERE rr.id = %s
            """, (review_id,))
            result = cursor.fetchone()
            
            if not result or result['user_id'] != session['user_id']:
                flash('Unauthorized! Only the recipe author can reply.', 'danger')
                return redirect(url_for('view_recipe', recipe_id=result['recipe_id'] if result else 0))
            
            recipe_id = result['recipe_id']
            
            # Update the review with the author's reply
            cursor.execute("""
                UPDATE recipe_ratings 
                SET author_reply = %s, replied_at = CURRENT_TIMESTAMP 
                WHERE id = %s
            """, (reply_content, review_id))
            connection.commit()
            
            flash('Your response has been posted!', 'success')
            return redirect(url_for('view_recipe', recipe_id=recipe_id))
    except Exception as e:
        print(f"Error replying to review: {e}")
        flash('Error posting reply!', 'danger')
        return redirect(url_for('index'))
    finally:
        connection.close()

# Toggle favorite
@app.route('/recipe/<int:recipe_id>/favorite', methods=['POST'], endpoint='favorite_recipe')
def toggle_favorite(recipe_id):
    if 'user_id' not in session:
        flash('Please login to favorite recipes!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    
    try:
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT * FROM recipe_favorites 
                WHERE recipe_id = %s AND user_id = %s
            """, (recipe_id, session['user_id']))
            existing = cursor.fetchone()
            
            if existing:
                cursor.execute("""
                    DELETE FROM recipe_favorites 
                    WHERE recipe_id = %s AND user_id = %s
                """, (recipe_id, session['user_id']))
                message = 'Recipe removed from favorites!'
            else:
                cursor.execute("""
                    INSERT INTO recipe_favorites (recipe_id, user_id)
                    VALUES (%s, %s)
                """, (recipe_id, session['user_id']))
                message = 'Recipe added to favorites!'
            
            connection.commit()
        
        if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
            return jsonify({'success': True, 'message': message, 'is_favorited': not existing})
            
        flash(message, 'success')
        return redirect(url_for('view_recipe', recipe_id=recipe_id))
    finally:
        connection.close()

# Toggle follow
@app.route('/profile/toggle-follow/<int:user_id>', methods=['POST'])
def toggle_follow(user_id):
    if 'user_id' not in session:
        return jsonify({'error': 'Login required'}), 401
    
    # Can't follow yourself
    if session['user_id'] == user_id:
        return jsonify({'error': 'You cannot follow yourself'}), 400
        
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection error'}), 500
        
    try:
        with connection.cursor() as cursor:
            # Check if already following
            cursor.execute("SELECT id FROM user_follows WHERE follower_id = %s AND followed_id = %s", 
                         (session['user_id'], user_id))
            follow = cursor.fetchone()
            
            if follow:
                # Unfollow
                cursor.execute("DELETE FROM user_follows WHERE id = %s", (follow['id'],))
                return jsonify({'success': True, 'following': False, 'message': 'Unfollowed successfully'})
            else:
                # Follow
                cursor.execute("INSERT INTO user_follows (follower_id, followed_id) VALUES (%s, %s)", 
                             (session['user_id'], user_id))
                return jsonify({'success': True, 'following': True, 'message': 'Followed successfully'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        connection.close()

# Remove a follower
@app.route('/profile/remove-follower/<int:follower_id>', methods=['POST'])
def remove_follower(follower_id):
    if 'user_id' not in session:
        return jsonify({'error': 'Login required'}), 401
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'error': 'Database connection error'}), 500
        
    try:
        with connection.cursor() as cursor:
            # Check if this person is actually following the current user
            cursor.execute("SELECT id FROM user_follows WHERE follower_id = %s AND followed_id = %s", 
                         (follower_id, session['user_id']))
            follow = cursor.fetchone()
            
            if follow:
                # Remove follower
                cursor.execute("DELETE FROM user_follows WHERE id = %s", (follow['id'],))
                connection.commit()
                return jsonify({'success': True, 'message': 'Follower removed successfully'})
            else:
                return jsonify({'error': 'This user is not following you'}), 400
    except Exception as e:
        connection.rollback()
        print(f"Error removing follower: {e}")
        return jsonify({'error': 'Server error'}), 500
    finally:
        connection.close()

# Search recipes
@app.route('/search', endpoint='search')
def search_recipes():
    query = request.args.get('q', '')
    category_id = request.args.get('category', '')
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return render_template('search.html', recipes=[], categories=[], query=query, selected_category=category_id)
    
    try:
        with connection.cursor() as cursor:
            base_query = """
                SELECT r.*, u.username, c.name as category_name,
                       IFNULL(AVG(rr.rating), 0) as avg_rating,
                       COUNT(rr.id) as rating_count
                FROM recipes r
                JOIN users u ON r.user_id = u.id
                LEFT JOIN categories c ON r.category_id = c.id
                LEFT JOIN recipe_ratings rr ON r.id = rr.recipe_id
                WHERE 1=1
            """
            params = []
            
            if query:
                base_query += " AND (r.title LIKE %s OR r.description LIKE %s OR r.ingredients LIKE %s)"
                params.extend([f'%{query}%', f'%{query}%', f'%{query}%'])
            
            if category_id:
                base_query += " AND r.category_id = %s"
                params.append(int(category_id))
            
            base_query += " GROUP BY r.id ORDER BY r.created_at DESC"
            
            cursor.execute(base_query, params)
            recipes = cursor.fetchall()
            
            cursor.execute("SELECT * FROM categories ORDER BY name")
            categories = cursor.fetchall()

            # Get favorite recipe IDs for current user
            user_favorites = []
            if 'user_id' in session:
                cursor.execute("SELECT recipe_id FROM recipe_favorites WHERE user_id = %s", (session['user_id'],))
                user_favorites = [f['recipe_id'] for f in cursor.fetchall()]
                
            # Search users finding matching chefs
            users = []
            if query:
                user_query = "SELECT id, username, profile_image FROM users WHERE username LIKE %s ORDER BY username LIMIT 10"
                cursor.execute(user_query, (f'%{query}%',))
                users = cursor.fetchall()
        
        return render_template('search.html', recipes=recipes, categories=categories, 
                             query=query, selected_category=category_id, user_favorites=user_favorites, users=users)
    finally:
        connection.close()

# Edit recipe
@app.route('/recipe/<int:recipe_id>/edit', methods=['GET', 'POST'])
def edit_recipe(recipe_id):
    if 'user_id' not in session:
        flash('Please login to edit recipes!', 'danger')
        return redirect(url_for('login'))
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('index'))
    
    try:
        with connection.cursor() as cursor:
            # Get recipe details
            cursor.execute("""
                SELECT * FROM recipes WHERE id = %s AND user_id = %s
            """, (recipe_id, session['user_id']))
            recipe = cursor.fetchone()
            
            if not recipe:
                flash('Recipe not found or you do not have permission to edit it!', 'danger')
                return redirect(url_for('index'))
            
            if request.method == 'POST':
                title = request.form['title']
                description = request.form.get('description', '')
                ingredients = request.form['ingredients']
                instructions = request.form['instructions']
                prep_time = request.form.get('prep_time', 0) or 0
                cook_time = request.form.get('cook_time', 0) or 0
                servings = request.form.get('servings', 1) or 1
                difficulty = request.form.get('difficulty', 'Medium')
                category_id = request.form.get('category_id') or None
                video_url = request.form.get('video_url', '').strip()
                
                # Handle image upload
                image_url = recipe['image_url']  # Keep existing image by default
                if 'image' in request.files:
                    file = request.files['image']
                    if file and file.filename != '' and allowed_file(file.filename):
                        # Get file extension
                        filename = secure_filename(file.filename)
                        name, ext = os.path.splitext(filename)
                        
                        # Convert .jfif to .jpg for better compatibility
                        if ext.lower() == '.jfif':
                            ext = '.jpg'
                        
                        # Create new filename with timestamp
                        new_filename = f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{name}{ext}"
                        
                        # Process and save image with quality optimization
                        success = process_and_save_image(file, new_filename, app.config['UPLOAD_FOLDER'])
                        
                        if success:
                            print(f"Image processed successfully: {new_filename}")
                        else:
                            print(f"Image saved without processing: {new_filename}")
                        
                        image_url = new_filename
                
                cursor.execute("""
                    UPDATE recipes SET title = %s, description = %s, ingredients = %s, 
                                      instructions = %s, prep_time = %s, cook_time = %s, 
                                      servings = %s, difficulty = %s, image_url = %s, 
                                      category_id = %s, video_url = %s, updated_at = CURRENT_TIMESTAMP
                    WHERE id = %s AND user_id = %s
                """, (title, description, ingredients, instructions, int(prep_time), 
                      int(cook_time), int(servings), difficulty, image_url, category_id, 
                      video_url, recipe_id, session['user_id']))
                connection.commit()
                
                flash('Recipe updated successfully!', 'success')
                return redirect(url_for('view_recipe', recipe_id=recipe_id))
            
            # Get categories for the form
            cursor.execute("SELECT * FROM categories ORDER BY name")
            categories = cursor.fetchall()
            
        return render_template('edit_recipe.html', recipe=recipe, categories=categories)
    finally:
        connection.close()

# Delete recipe
@app.route('/recipe/<int:recipe_id>/delete', methods=['POST'])
def delete_recipe(recipe_id):
    if 'user_id' not in session:
        return jsonify({'success': False, 'message': 'Please login to delete recipes!'})
    
    connection = get_db_connection()
    if not connection:
        return jsonify({'success': False, 'message': 'Database connection error!'})
    
    try:
        with connection.cursor() as cursor:
            # Check if recipe exists and belongs to user
            cursor.execute("""
                SELECT * FROM recipes WHERE id = %s AND user_id = %s
            """, (recipe_id, session['user_id']))
            recipe = cursor.fetchone()
            
            if not recipe:
                return jsonify({'success': False, 'message': 'Recipe not found or you do not have permission to delete it!'})
            
            # Delete the recipe (cascading will handle related records)
            cursor.execute("""
                DELETE FROM recipes WHERE id = %s AND user_id = %s
            """, (recipe_id, session['user_id']))
            connection.commit()
        
        return jsonify({'success': True, 'message': 'Recipe deleted successfully!'})
    finally:
        connection.close()

# Settings route (Profile, Security, Preferences)
@app.route('/settings', methods=['GET', 'POST'])
def settings():
    if 'user_id' not in session:
        flash('Please login to access settings!', 'danger')
        return redirect(url_for('login'))
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('index'))
    
    try:
        with connection.cursor() as cursor:
            # Get current user data
            cursor.execute("SELECT * FROM users WHERE id = %s", (session['user_id'],))
            user = cursor.fetchone()
            
            if request.method == 'POST':
                action = request.form.get('action')
                
                # --- Unknown Action ---
                if not action:
                    flash('Invalid action', 'danger')
                
                # --- Update Profile ---
                elif action == 'update_profile':
                    first_name = request.form.get('first_name', '')
                    last_name = request.form.get('last_name', '')
                    bio = request.form.get('bio', '')
                    
                    # Handle profile image upload
                    profile_image = user['profile_image']  # Keep current image if no new one uploaded
                    if 'profile_image' in request.files:
                        file = request.files['profile_image']
                        if file and file.filename and allowed_file(file.filename):
                            filename = secure_filename(file.filename)
                            # Create unique filename
                            import time
                            timestamp = str(int(time.time()))
                            filename = f"profile_{session['user_id']}_{timestamp}_{filename}"
                            
                            # Save file with processing
                            if process_and_save_image(file, filename, app.config['UPLOAD_FOLDER']):
                                profile_image = filename
                            else:
                                flash('Error processing image. Please try again.', 'warning')
                    
                    # Update user data
                    cursor.execute("""
                        UPDATE users 
                        SET first_name = %s, last_name = %s, bio = %s, profile_image = %s, updated_at = CURRENT_TIMESTAMP
                        WHERE id = %s
                    """, (first_name, last_name, bio, profile_image, session['user_id']))
                    connection.commit()
                    
                    # Update session profile image
                    session['profile_image'] = profile_image
                    
                    flash('Profile updated successfully!', 'success')
                    return redirect(url_for('settings'))
                
                # --- Change Password ---
                elif action == 'change_password':
                    current_password = request.form.get('current_password')
                    new_password = request.form.get('new_password')
                    confirm_password = request.form.get('confirm_password')
                    
                    if not check_password_hash(user['password_hash'], current_password):
                        flash('Incorrect current password!', 'danger')
                    elif new_password != confirm_password:
                        flash('New passwords do not match!', 'danger')
                    elif len(new_password) < 6:
                        flash('Password must be at least 6 characters long!', 'danger')
                    else:
                        password_hash = generate_password_hash(new_password)
                        cursor.execute("""
                            UPDATE users SET password_hash = %s WHERE id = %s
                        """, (password_hash, session['user_id']))
                        connection.commit()
                        flash('Password updated successfully!', 'success')
                        return redirect(url_for('settings'))

                # --- Update Preferences ---
                elif action == 'update_preferences':
                    email_notifications = 1 if request.form.get('email_notifications') == 'on' else 0
                    newsletter = 1 if request.form.get('newsletter') == 'on' else 0
                    public_profile = 1 if request.form.get('public_profile') == 'on' else 0
                    
                    cursor.execute("""
                        UPDATE users 
                        SET email_notifications = %s, newsletter = %s, public_profile = %s, updated_at = CURRENT_TIMESTAMP
                        WHERE id = %s
                    """, (email_notifications, newsletter, public_profile, session['user_id']))
                    connection.commit()
                    
                    
                    return redirect(url_for('settings'))
        
        return render_template('settings.html', user=user)
    finally:
        connection.close()

# User profile
@app.route('/delete_account', methods=['POST'])
def delete_account():
    if 'user_id' not in session:
        flash('Please login to perform this action!', 'danger')
        return redirect(url_for('login'))
    
    user_id = session['user_id']
    
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('settings'))
    
    try:
        with connection.cursor() as cursor:
            # Delete user (Cascading deletes in DB should handle related data if configured, 
            # otherwise we might leave orphans, but user deletion is the priority)
            cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
            connection.commit()
            
        session.clear()
        flash('Your account has been permanently deleted.', 'success') # Success/Info to show on index
        return redirect(url_for('index'))
        
    except Exception as e:
        flash(f'An error occurred while deleting your account: {str(e)}', 'danger')
        return redirect(url_for('settings'))
    finally:
        connection.close()

@app.route('/profile/<username>', endpoint='profile')
def user_profile(username):
    connection = get_db_connection()
    if not connection:
        flash('Database connection error!', 'danger')
        return redirect(url_for('index'))
    
    try:
        with connection.cursor() as cursor:
            # Get user details
            cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
            user = cursor.fetchone()
            
            if not user:
                flash('User not found!', 'danger')
                return redirect(url_for('index'))
            
            # Get recipes created by user
            cursor.execute("""
                SELECT r.*, c.name as category_name,
                       IFNULL(AVG(rr_all.rating), 0) as avg_rating,
                       COUNT(rr_all.id) as rating_count
                FROM recipes r
                LEFT JOIN categories c ON r.category_id = c.id
                LEFT JOIN recipe_ratings rr_all ON r.id = rr_all.recipe_id
                WHERE r.user_id = %s
                GROUP BY r.id
                ORDER BY r.created_at DESC
            """, (user['id'],))
            recipes = cursor.fetchall()

            # Get recipes rated by user
            cursor.execute("""
                SELECT r.*, c.name as category_name,
                       rr.rating as user_given_rating,
                       rr.review as user_review,
                       IFNULL(u_author.username, 'Unknown Chef') as author_name,
                       (SELECT IFNULL(AVG(rating), 0) FROM recipe_ratings WHERE recipe_id = r.id) as avg_rating
                FROM recipe_ratings rr
                JOIN recipes r ON rr.recipe_id = r.id
                LEFT JOIN users u_author ON r.user_id = u_author.id
                LEFT JOIN categories c ON r.category_id = c.id
                WHERE rr.user_id = %s
                ORDER BY rr.created_at DESC
            """, (user['id'],))
            rated_recipes = cursor.fetchall()

            # Get recipes favorited by user
            cursor.execute("""
                SELECT r.*, IFNULL(u_author.username, 'Unknown Chef') as author_name, c.name as category_name,
                       IFNULL(AVG(rr_all.rating), 0) as avg_rating,
                       COUNT(rr_all.id) as rating_count
                FROM recipe_favorites rf
                JOIN recipes r ON rf.recipe_id = r.id
                LEFT JOIN users u_author ON r.user_id = u_author.id
                LEFT JOIN categories c ON r.category_id = c.id
                LEFT JOIN recipe_ratings rr_all ON r.id = rr_all.recipe_id
                WHERE rf.user_id = %s
                GROUP BY r.id
                ORDER BY rf.created_at DESC
            """, (user['id'],))
            favorite_recipes = cursor.fetchall()

            # Get aggregate stats for profile header
            # 1. Total Favorites count
            cursor.execute("SELECT COUNT(*) as count FROM recipe_favorites WHERE user_id = %s", (user['id'],))
            fav_count = cursor.fetchone()['count']

            # 2. Average rating of user's own recipes
            cursor.execute("""
                SELECT AVG(rr.rating) as avg_score
                FROM recipes r
                JOIN recipe_ratings rr ON r.id = rr.recipe_id
                WHERE r.user_id = %s
            """, (user['id'],))
            score_res = cursor.fetchone()
            user_avg_score = float(score_res['avg_score']) if score_res['avg_score'] else 0

            # 3. Follow stats
            # Fetch followers and check if current user follows them
            cursor.execute("""
                SELECT u.id, u.username, u.profile_image,
                       (SELECT 1 FROM user_follows WHERE follower_id = %s AND followed_id = u.id) as is_followed_by_current
                FROM users u
                JOIN user_follows uf ON u.id = uf.follower_id
                WHERE uf.followed_id = %s
            """, (session.get('user_id', 0), user['id']))
            followers = cursor.fetchall()
            follower_count = len(followers)
            
            # Fetch following and check if current user follows them
            cursor.execute("""
                SELECT u.id, u.username, u.profile_image,
                       (SELECT 1 FROM user_follows WHERE follower_id = %s AND followed_id = u.id) as is_followed_by_current
                FROM users u
                JOIN user_follows uf ON u.id = uf.followed_id
                WHERE uf.follower_id = %s
            """, (session.get('user_id', 0), user['id']))
            following = cursor.fetchall()
            following_count = len(following)
            
            is_following = False
            if 'user_id' in session:
                cursor.execute("SELECT id FROM user_follows WHERE follower_id = %s AND followed_id = %s", 
                             (session['user_id'], user['id']))
                if cursor.fetchone():
                    is_following = True

            # Compute achievement badges
            user_badges = get_user_badges(cursor, user['id'])
        
        return render_template('profile.html', user=user, recipes=recipes, 
                             rated_recipes=rated_recipes, favorite_recipes=favorite_recipes,
                             fav_count=fav_count, user_avg_score=user_avg_score,
                             follower_count=follower_count, following_count=following_count,
                             followers=followers, following_list=following,
                             is_following=is_following,
                             user_badges=user_badges)
    finally:
        connection.close()

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/faq')
def faq():
    return render_template('faq.html')

@app.route('/contact', methods=['GET', 'POST'])
def contact():
    if request.method == 'POST':
        name = request.form.get('name')
        email = request.form.get('email')
        subject = request.form.get('subject')
        message = request.form.get('message')
        
        if not name or not email or not message:
            flash('Please fill in all required fields.', 'danger')
            return redirect(url_for('contact'))
            
        connection = get_db_connection()
        if not connection:
            flash('Database connection error!', 'danger')
            return redirect(url_for('contact'))
            
        try:
            with connection.cursor() as cursor:
                cursor.execute("""
                    INSERT INTO contact_queries (name, email, subject, message)
                    VALUES (%s, %s, %s, %s)
                """, (name, email, subject, message))
                connection.commit()
            flash('Your message has been sent successfully! We will get back to you soon.', 'success')
            return redirect(url_for('index'))
        except Exception as e:
            print(f"Error saving contact query: {e}")
            flash('An error occurred while sending your message. Please try again.', 'danger')
        finally:
            connection.close()
            
    return render_template('contact.html')

# --- Admin Section ---
@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if session.get('is_admin'):
        return redirect(url_for('admin_dashboard'))
        
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if username == 'nepals' and password == 'nepals':
            session['is_admin'] = True
            session['username'] = 'Admin (Nepal)'
            flash('Admin login successful!', 'success')
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Invalid admin credentials', 'error')
            
    return render_template('admin/login.html')

@app.route('/admin/logout')
def admin_logout():
    session.pop('is_admin', None)
    flash('Logged out from admin panel', 'info')
    return redirect(url_for('admin_login'))

@app.route('/admin/dashboard')
def admin_dashboard():
    if not session.get('is_admin'):
        return redirect(url_for('admin_login'))
        
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # Stats
            cursor.execute("SELECT COUNT(*) as count FROM recipes")
            recipe_count = cursor.fetchone()['count']
            
            cursor.execute("SELECT COUNT(*) as count FROM users")
            user_count = cursor.fetchone()['count']
            
            cursor.execute("SELECT COUNT(*) as count FROM recipe_ratings")
            review_count = cursor.fetchone()['count']
            
            # Recent Recipes (for Activity Stream)
            cursor.execute("""
                SELECT r.*, u.username, c.name as category_name
                FROM recipes r 
                JOIN users u ON r.user_id = u.id 
                LEFT JOIN categories c ON r.category_id = c.id
                ORDER BY r.created_at DESC LIMIT 5
            """)
            recent_recipes = cursor.fetchall()

            # All Recipes (for Inventory Management)
            cursor.execute("""
                SELECT r.*, u.username, c.name as category_name
                FROM recipes r 
                JOIN users u ON r.user_id = u.id 
                LEFT JOIN categories c ON r.category_id = c.id
                ORDER BY r.created_at DESC
            """)
            all_recipes = cursor.fetchall()
            
            # Recent Users
            cursor.execute("SELECT * FROM users ORDER BY created_at DESC")
            recent_users = cursor.fetchall()
            
            # All Users for Users tab
            cursor.execute("SELECT * FROM users ORDER BY created_at DESC")
            all_users = cursor.fetchall()

            # All Feedbacks for Feedback tab
            cursor.execute("""
                SELECT rr.*, u.username as reviewer_name, r.title as recipe_title 
                FROM recipe_ratings rr
                JOIN users u ON rr.user_id = u.id
                JOIN recipes r ON rr.recipe_id = r.id
                ORDER BY rr.created_at DESC
            """)
            all_feedbacks = cursor.fetchall()
            
            # Trending Category (Sum of views in category)
            cursor.execute("""
                SELECT c.name 
                FROM recipes r
                JOIN categories c ON r.category_id = c.id
                GROUP BY c.id
                ORDER BY SUM(r.views) DESC
                LIMIT 1
            """)
            trending_cat_res = cursor.fetchone()
            trending_category = trending_cat_res['name'] if trending_cat_res else 'None'

            # Avg Community Rating
            cursor.execute("SELECT AVG(rating) as avg_rating FROM recipe_ratings")
            rating_res = cursor.fetchone()
            avg_community_rating = round(float(rating_res['avg_rating']), 1) if rating_res['avg_rating'] else 0.0

            # Categories
            cursor.execute("SELECT * FROM categories")
            categories = cursor.fetchall()

            # Support Queries
            cursor.execute("SELECT * FROM contact_queries ORDER BY created_at DESC")
            support_queries = cursor.fetchall()
            cursor.execute("SELECT COUNT(*) as count FROM contact_queries WHERE status = 'Pending'")
            pending_queries_count = cursor.fetchone()['count']

        return render_template('admin/dashboard.html', 
                             recipe_count=recipe_count, 
                             user_count=user_count, 
                             review_count=review_count,
                             recent_recipes=recent_recipes,
                             all_recipes=all_recipes,
                             recent_users=recent_users,
                             all_users=all_users,
                             all_feedbacks=all_feedbacks,
                             trending_category=trending_category,
                             avg_community_rating=avg_community_rating,
                             categories=categories,
                             support_queries=support_queries,
                             pending_queries_count=pending_queries_count,
                             now=datetime.now())
    finally:
        connection.close()

@app.route('/admin/delete_recipe/<int:recipe_id>', methods=['POST'])
def admin_delete_recipe(recipe_id):
    if not session.get('is_admin'):
        return jsonify({'error': 'Unauthorized'}), 403
        
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # Get image url first
            cursor.execute("SELECT image_url FROM recipes WHERE id = %s", (recipe_id,))
            recipe = cursor.fetchone()
            if recipe and recipe['image_url']:
                try:
                    os.remove(os.path.join(app.config['UPLOAD_FOLDER'], recipe['image_url']))
                except:
                    pass
            
            cursor.execute("DELETE FROM recipes WHERE id = %s", (recipe_id,))
            connection.commit() # Added commit for consistency
        flash('Recipe deleted successfully.', 'success') # Added flash message
        return redirect(url_for('admin_dashboard'))
    finally:
        connection.close()

@app.route('/admin/delete_user/<int:user_id>', methods=['POST'])
def admin_delete_user(user_id):
    if not session.get('is_admin'): return jsonify({'error': 'Unauthorized'}), 403
    connection = get_db_connection() # Re-added connection handling
    try:
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM users WHERE id = %s", (user_id,))
            connection.commit() # Changed from mysql.connection.commit()
        flash('User deleted successfully.', 'success')
        return redirect(url_for('admin_dashboard'))
    finally:
        connection.close()

@app.route('/admin/delete_feedback/<int:rating_id>', methods=['POST'])
def admin_delete_feedback(rating_id):
    if not session.get('is_admin'): return jsonify({'error': 'Unauthorized'}), 403
    connection = get_db_connection() # Re-added connection handling
    try:
        with connection.cursor() as cursor:
            cursor.execute("DELETE FROM recipe_ratings WHERE id = %s", (rating_id,))
            connection.commit() # Changed from mysql.connection.commit()
        flash('Feedback purged successfully.', 'success')
        return redirect(url_for('admin_dashboard'))
    finally:
        connection.close()

@app.route('/admin/add_category', methods=['POST'])
def admin_add_category():
    if not session.get('is_admin'):
        return jsonify({'error': 'Unauthorized'}), 403
        
    name = request.form.get('name')
    if name:
        connection = get_db_connection()
        try:
            with connection.cursor() as cursor:
                cursor.execute("INSERT INTO categories (name) VALUES (%s)", (name,))
            flash('Category added successfully!', 'success')
        finally:
            connection.close()
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/delete_category/<int:category_id>', methods=['POST'])
def admin_delete_category(category_id):
    if not session.get('is_admin'):
        return jsonify({'error': 'Unauthorized'}), 403
        
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            # Set category_id to NULL for recipes using this category
            cursor.execute("UPDATE recipes SET category_id = NULL WHERE category_id = %s", (category_id,))
            # Delete the category
            cursor.execute("DELETE FROM categories WHERE id = %s", (category_id,))
            connection.commit()
        flash('Category deleted successfully!', 'success')
    except Exception as e:
        flash(f'Error deleting category: {str(e)}', 'error')
    finally:
        connection.close()
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/resolve_query/<int:query_id>', methods=['POST'])
def admin_resolve_query(query_id):
    if not session.get('is_admin'):
        return jsonify({'error': 'Unauthorized'}), 403
        
    connection = get_db_connection()
    try:
        with connection.cursor() as cursor:
            cursor.execute("UPDATE contact_queries SET status = 'Resolved' WHERE id = %s", (query_id,))
            connection.commit()
        flash('Query marked as resolved!', 'success')
    except Exception as e:
        flash(f'Error resolving query: {str(e)}', 'error')
    finally:
        connection.close()
    return redirect(url_for('admin_dashboard'))

@app.route('/how-it-works')
def how_it_works():
    return render_template('how_it_works.html')

if __name__ == '__main__':
    app.run(debug=True)
