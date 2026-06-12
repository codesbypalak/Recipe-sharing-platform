-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 14, 2026 at 04:06 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `recipe_sharing`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `icon` varchar(50) DEFAULT 'utensils'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `created_at`, `icon`) VALUES
(7, 'Breakfast', 'Morning meals and breakfast dishes', '2026-01-30 14:53:02', 'egg'),
(9, 'Lunch', 'Main dishes and entrees for lunch', '2026-02-01 10:44:13', 'hamburger'),
(10, 'Dinner', 'Evening meals and dinner dishes', '2026-02-01 10:44:13', 'utensils'),
(11, 'Dessert', 'Sweet treats and desserts', '2026-02-01 10:44:13', 'ice-cream'),
(12, 'Quick Bites', 'Fast and easy snacks or small meals', '2026-02-01 10:44:13', 'pizza-slice');

-- --------------------------------------------------------

--
-- Table structure for table `contact_queries`
--

CREATE TABLE `contact_queries` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `status` enum('Pending','Resolved') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `contact_queries`
--

INSERT INTO `contact_queries` (`id`, `name`, `email`, `subject`, `message`, `status`, `created_at`) VALUES
(1, 'yashvi', 'yashvi12@gmail.com', 'about recipe', 'I want to know i can download recipe offline ?', 'Pending', '2026-03-08 16:30:05');

-- --------------------------------------------------------

--
-- Table structure for table `recipes`
--

CREATE TABLE `recipes` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `ingredients` text NOT NULL,
  `instructions` text NOT NULL,
  `prep_time` int(11) DEFAULT NULL,
  `cook_time` int(11) DEFAULT NULL,
  `servings` int(11) DEFAULT NULL,
  `difficulty` enum('Easy','Medium','Hard') DEFAULT 'Medium',
  `image_url` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `views` int(11) DEFAULT 0,
  `video_url` varchar(512) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recipes`
--

INSERT INTO `recipes` (`id`, `title`, `description`, `ingredients`, `instructions`, `prep_time`, `cook_time`, `servings`, `difficulty`, `image_url`, `user_id`, `category_id`, `created_at`, `updated_at`, `views`, `video_url`) VALUES
(8, 'Dal Makhani', 'Dal Makhani is a rich, creamy, and mildly spiced Punjabi lentil curry made primarily with whole black lentils (sabut urad dal) and red kidney beans (rajma)', 'Lentils: 1 cup Whole Urad Dal (Black Lentils) & 1/4 cup Rajma (Kidney Beans)\r\nAromatics/Spices: 1 large onion (chopped), 2 tsp ginger-garlic paste, 1-2 green chilies, 1 tsp cumin seeds, 1 tsp Kashmiri red chili powder, 1/2 tsp garam masala\r\nLiquid & Fat: 3-4 tbsp Butter/Ghee, 1/4 cup Heavy Cream, 2-3 cups Tomato Puree (or chopped tomatoes)\r\nHerb: 1 tsp Kasuri Methi (dried fenugreek leaves) ', 'Boil: Pressure cook the soaked dal and rajma with salt and enough water for 10–12 whistles (about 30–40 minutes) until completely soft and mushy.\r\nSauté: In a separate pan, heat butter/ghee. Sauté whole spices, then add onions and ginger-garlic paste until golden.\r\nSimmer: Add tomato puree and chili powder, cooking until oil separates.\r\nCombine: Mix the boiled lentils into the masala. Mash some lentils with a spoon to thicken the texture.\r\nFinish: Simmer on low heat for at least 30 minutes, adding water as needed. Stir in cream, extra butter, and crushed kasuri methi (dried fenugreek) before serving.', 0, 0, 4, 'Medium', '20260204_151251_Dal-Makhani-recipe-scaled.webp', 3, 10, '2026-02-04 09:42:54', '2026-03-10 03:44:37', 4, 'https://youtu.be/JaZYpDp5dN4?si=A43UwwVGUGgj9xF8'),
(10, 'Egg Fried Rice', 'Egg Fried Rice is a quick and delicious Indo-Chinese dish made by stir-frying cooked rice with scrambled eggs, garlic, vegetables, and soy sauce. It has a mild smoky flavor, soft eggs, and perfectly seasoned rice. This dish is easy to prepare, filling, and is commonly served hot as a main course or as an accompaniment with gravies and sauces.', 'Cooked rice – 2 cups (preferably cold/day-old)\r\n\r\nEggs – 2\r\n\r\nOil – 2 tablespoons\r\n\r\nGarlic – 1 teaspoon (finely chopped)\r\n\r\nOnion – 1 small (finely chopped)\r\n\r\nGreen chilli – 1 (optional, finely chopped)\r\n\r\nSpring onions – 2 tablespoons (optional)\r\n\r\nSoy sauce – 1 tablespoon\r\n\r\nSalt – to taste\r\n\r\nBlack pepper – ½ teaspoon\r\n\r\nOptional vegetables: carrot, beans, capsicum (¼ cup chopped)', 'Cook rice in advance and let it cool completely (best if refrigerated).\r\nChop all vegetables, garlic, and onions.\r\nBeat eggs lightly with a pinch of salt and pepper.\r\nHeat oil in a wok or pan on medium flame.\r\nAdd beaten eggs and scramble them quickly. Remove and keep aside.\r\nIn the same pan, add a little more oil if needed.\r\nAdd garlic and green chilli, sauté for a few seconds.\r\nAdd onion and vegetables, stir-fry for 2–3 minutes.\r\nAdd cooked rice and mix well, breaking lumps gently.\r\nAdd soy sauce, salt, and black pepper. Mix on high flame.\r\nAdd scrambled eggs back to the pan and toss well.\r\nAdd spring onions and stir-fry for 1 more minute.', 10, 15, 2, 'Easy', '20260217_184549_eggfriedrice.webp', 1, 9, '2026-02-17 13:15:50', '2026-03-04 17:05:42', 7, 'https://youtu.be/GfyJS-flQQo?si=19BOnkMSM_Q4FKr0'),
(12, 'Poha', 'Description:\r\nPoha is a light, healthy, and quick Indian breakfast dish made from flattened rice cooked with onions, mustard seeds, curry leaves, peanuts, and mild spices. It has a soft texture, gentle flavors, and a refreshing taste from lemon juice. Poha is easy to digest and commonly served hot with tea, often garnished with coriander, sev, or pomegranate.', 'Poha (flattened rice) – 2 cups\r\n\r\nOil – 2 tablespoons\r\n\r\nMustard seeds – ½ teaspoon\r\n\r\nCurry leaves – 8–10\r\n\r\nOnion – 1 medium (finely chopped)\r\n\r\nGreen chilli – 1 (finely chopped)\r\n\r\nTurmeric powder – ¼ teaspoon\r\n\r\nSalt – to taste\r\n\r\nSugar – ½ teaspoon (optional)\r\n\r\nLemon juice – 1 tablespoon\r\n\r\nPeanuts – 2 tablespoons\r\n\r\nCoriander leaves – 2 tablespoons (chopped)', 'Put poha in a strainer and rinse under water for a few seconds.\r\nLet it rest for 5 minutes until soft.\r\nAdd salt and turmeric to the poha and mix gently.\r\nChop onions, green chilli, coriander, and keep ready.\r\nHeat oil in a pan on medium flame.\r\nAdd mustard seeds and let them crackle.\r\nAdd peanuts and roast till crispy.\r\nAdd curry leaves, green chilli, and onion. Sauté till onion turns soft.\r\nAdd the softened poha and mix gently.\r\nAdd sugar (if using) and cook for 2–3 minutes on low flame.\r\nTurn off the flame and add lemon juice.\r\nMix well and garnish with coriander leaves.', 32, 79, 42, 'Easy', '20260217_192355_Poha.jpg', 1, 7, '2026-02-17 13:43:30', '2026-03-04 17:05:37', 5, 'https://youtu.be/pNzxeWcbVtU?si=9Z5eQUAHbtIqL_5O'),
(13, 'Idli Sambhar', 'Idli Sambar is a classic South Indian dish consisting of soft, steamed rice cakes (idli) served with hot, flavorful sambar made from lentils, vegetables, and aromatic spices. It is light, nutritious, easy to digest, and commonly enjoyed as a breakfast or dinner, often accompanied by coconut chutney.', 'Idli batter – 2 cups\r\nToor dal – ½ cup\r\nWater – 2 cups\r\nSambar powder – 1½ tablespoons\r\nTamarind pulp – 1 tablespoon\r\nMixed vegetables – 1 cup (carrot, drumstick, potato, brinjal)\r\nOnion – 1 small (optional)\r\nTomato – 1 medium\r\nSalt – to taste\r\nTurmeric powder – ¼ teaspoon\r\nOil – 2 tablespoons\r\nMustard seeds – ½ teaspoon\r\nDry red chilli – 1\r\nCurry leaves – 8–10\r\nAsafoetida (hing) – a pinch', 'Grease idli moulds lightly.\r\nPour batter into moulds.\r\nSteam for 10–12 minutes.\r\nCool slightly and remove idlis.\r\nCook vegetables with turmeric and salt until soft.\r\nAdd tamarind pulp and sambar powder, boil for 5 minutes.\r\nAdd mashed dal and water as needed. Simmer 5–10 minutes.\r\nPrepare tempering: heat oil, add mustard seeds, red chilli, curry leaves, and hing.\r\nPour tempering over sambar and mix well.', 20, 50, 2, 'Medium', '20260217_195558_Idli.jpg', 2, 10, '2026-02-17 14:25:58', '2026-03-05 04:23:34', 8, 'https://www.youtube.com/watch?v=xGmHqaLeukU'),
(14, 'Ghughra', 'Masala Ghughra is a popular Gujarati snack made from crisp, deep-fried pastry filled with a spicy mixture of mashed potatoes, peas, and aromatic Indian spices. Shaped like a half-moon, it is crunchy on the outside and flavorful inside, commonly enjoyed hot with chutney as a tea-time snack or festive food.', 'For Outer Cover:\r\nMaida (all-purpose flour) – 2 cups\r\nOil or ghee – 2 tablespoons\r\nSalt – a pinch\r\nWater – as needed (to make stiff dough)\r\nFor Masala Filling:\r\nBoiled potatoes – 3 (mashed)\r\nGreen peas – ½ cup (boiled & mashed)\r\nGreen chilli – 1–2 (finely chopped)\r\nGinger – 1 teaspoon (grated)\r\nCumin seeds – ½ teaspoon\r\nTurmeric powder – ¼ teaspoon\r\nRed chilli powder – ½ teaspoon\r\nCoriander powder – 1 teaspoon\r\nGaram masala – ½ teaspoon\r\nSugar – ½ teaspoon (optional)\r\nLemon juice – 1 tablespoon\r\nSalt – to taste\r\nFresh coriander – 2 tablespoons (chopped)\r\nOil – for deep frying', 'Mix maida, salt, and oil. Add water gradually to make a stiff dough. Cover and rest for 15 minutes.\r\n\r\nPrepare the filling by mashing potatoes and peas.\r\n\r\nChop green chilli, ginger, and coriander.\r\n\r\nHeat oil in a pan, add cumin seeds.\r\n\r\nAdd ginger and green chilli; sauté briefly.\r\n\r\nAdd all spices and salt; mix well.\r\n\r\nAdd mashed potatoes and peas. Cook for 2–3 minutes.\r\n\r\nAdd lemon juice and coriander. Let the filling cool.\r\n\r\nDivide dough into small balls and roll into small discs.\r\n\r\nPlace filling in the center, fold into a half-moon shape, and seal edges tightly.\r\n\r\nHeat oil on medium flame and deep-fry ghughra till golden and crispy.\r\n\r\nRemove and drain excess oil.', 25, 20, 2, 'Easy', '20260217_200449_Ghughra.jpg', 2, 12, '2026-02-17 14:34:49', '2026-03-05 04:15:22', 3, NULL),
(15, 'Jalebi', 'Jalebi is a popular Indian sweet made by deep-frying fermented batter in spiral shapes and soaking them in warm sugar syrup. It is crispy on the outside, soft inside, and has a sweet, juicy taste. Jalebi is commonly enjoyed hot as a dessert or breakfast sweet, often served with milk or curd.', 'Maida (all-purpose flour) – 1 cup\r\n\r\nCornflour – 2 tablespoons\r\n\r\nCurd – ½ cup\r\n\r\nBaking soda – a pinch\r\n\r\nWater – as needed\r\n\r\nFood colour – a pinch (optional)\r\n\r\nSugar – 1 cup\r\n\r\nWater – ½ cup\r\n\r\nCardamom powder – ¼ teaspoon\r\n\r\nLemon juice – 1 teaspoon\r\n\r\nGhee or oil – for deep frying', 'Mix maida, cornflour, curd, baking soda, and water to make a smooth batter.\r\n\r\nAdd food colour if using.\r\n\r\nCover and ferment the batter overnight or for 8–10 hours.\r\n\r\nHeat oil or ghee on medium flame.\r\n\r\nPour batter into a piping bag or bottle.\r\n\r\nSqueeze batter into hot oil in spiral shapes.\r\n\r\nFry till crisp and golden.\r\n\r\nImmediately dip hot jalebis into warm sugar syrup for 1–2 minutes.\r\n\r\nRemove and serve.', 10, 20, 2, 'Easy', '20260218_101611_Jalebi.jpg', 3, 11, '2026-02-18 04:46:11', '2026-03-08 16:14:51', 7, 'https://youtu.be/pdFm9Rnz4H8?si=gJdpycQjSDhqgBty'),
(16, 'Veg Biryani', 'Veg Biryani is a flavorful and aromatic rice dish made by cooking basmati rice with mixed vegetables, whole spices, herbs, and biryani masala. It has rich taste, layered flavors, and a fragrant aroma, making it a popular main-course dish served on special occasions or as a complete meal.', 'Basmati rice – 2 cups\r\n\r\nMixed vegetables – 2 cups (carrot, beans, peas, potato, cauliflower)\r\n\r\nOnion – 2 large (thinly sliced)\r\n\r\nTomato – 1 medium (chopped)\r\n\r\nGinger-garlic paste – 1 tablespoon\r\n\r\nGreen chilli – 1–2 (slit)\r\n\r\nCurd – ½ cup\r\n\r\nBiryani masala – 2 tablespoons\r\n\r\nRed chilli powder – ½ teaspoon\r\n\r\nTurmeric powder – ¼ teaspoon\r\n\r\nGaram masala – ½ teaspoon\r\n\r\nWhole spices: bay leaf, cinnamon, cloves, cardamom\r\n\r\nMint leaves – ¼ cup\r\n\r\nCoriander leaves – ¼ cup\r\n\r\nOil or ghee – 3 tablespoons\r\n\r\nSalt – to taste\r\n\r\nWater – as needed', 'Wash and soak basmati rice for 30 minutes.\r\n\r\nChop vegetables, onions, tomatoes, and herbs.\r\n\r\nPrepare ginger-garlic paste.\r\n\r\nCook rice in boiling water with whole spices until 70% done. Drain and keep aside.\r\n\r\nHeat oil/ghee in a pot. Fry onions till golden brown.\r\n\r\nAdd ginger-garlic paste and green chilli; sauté well.\r\n\r\nAdd tomatoes, spices, salt, and cook till oil separates.\r\n\r\nAdd vegetables and cook for 5 minutes.\r\n\r\nAdd curd, mint, and coriander; mix gently.\r\n\r\nLayer partially cooked rice over the vegetables.\r\n\r\nCover and cook on low flame (dum) for 10–15 minutes.\r\n\r\nSwitch off heat and rest for 5 minutes before serving.', 20, 30, 3, 'Medium', '20260218_104554_Veg_Biryani.jpg', 3, 10, '2026-02-18 05:15:54', '2026-03-08 16:14:48', 4, 'https://youtu.be/Do7ZdUodDdw?si=BiLG8NcsTEKuXqBW'),
(17, 'Khaman/Dhokla', 'Khaman is a soft, fluffy, and slightly tangy Gujarati snack made from gram flour (besan) and steamed to perfection. It is light, spongy, and mildly sweet, commonly enjoyed as a breakfast or tea-time snack, tempered with mustard seeds and curry leaves.', 'Besan (gram flour) – 1 cup\r\n\r\nSemolina (rava) – 1 tablespoon (optional)\r\n\r\nCurd – ½ cup\r\n\r\nWater – ½ cup\r\n\r\nSugar – 1 tablespoon\r\n\r\nSalt – to taste\r\n\r\nTurmeric powder – a pinch\r\n\r\nLemon juice – 1 tablespoon\r\n\r\nEno fruit salt – 1 teaspoon (or baking soda ½ tsp)\r\n\r\nOil – 2 tablespoons\r\n\r\nMustard seeds – ½ teaspoon\r\n\r\nCurry leaves – 8–10\r\n\r\nGreen chilli – 1–2 (slit)\r\n\r\nWater – 2 tablespoons\r\n\r\nSugar – 1 teaspoon (optional)\r\n\r\nFresh coriander – chopped', 'Mix besan, rava, curd, water, sugar, salt, turmeric, and lemon juice.\r\n\r\nWhisk to a smooth, lump-free batter.\r\n\r\nKeep batter resting for 10 minutes.\r\n\r\nGrease a steaming plate or tin.\r\n\r\nAdd Eno to the batter and mix gently.\r\n\r\nImmediately pour batter into greased plate.\r\n\r\nSteam for 15–20 minutes or until a knife comes out clean.\r\n\r\nLet it cool slightly and cut into pieces.\r\n\r\nPrepare tempering: heat oil, add mustard seeds, curry leaves, and green chilli.\r\n\r\nAdd water and sugar, boil for a few seconds.\r\n\r\nPour tempering evenly over khaman.\r\n\r\nServe soft khaman with green chutney.\r\n\r\nGarnish with coriander and coconut.\r\n', 10, 15, 2, 'Easy', '20260218_204415_Khaman.jpg', 1, 7, '2026-02-18 15:14:15', '2026-03-06 04:08:06', 6, 'https://youtu.be/w_2eb9uaXns?si=gHfWPbPFBloqoXVB'),
(18, 'Aloo Paratha', 'Aloo Paratha is a popular North Indian breakfast dish made with whole wheat dough stuffed with a spiced mashed potato filling. It’s crispy outside, soft inside, and super comforting!', '2 cups whole wheat flour (atta)\r\n½ tsp salt\r\nWater (as needed)\r\n1 tbsp oil (optional)\r\n3 medium potatoes (boiled & mashed)\r\n1 small onion (finely chopped, optional)\r\n1–2 green chilies (finely chopped)\r\n½ tsp cumin seeds\r\n½ tsp red chili powder\r\n½ tsp garam masala\r\n½ tsp dry mango powder (amchur) or lemon juice\r\n2 tbsp fresh coriander (chopped)\r\nSalt to taste\r\nGhee or oil', 'In a bowl, mix flour and salt.\r\nGradually add water and knead into a soft dough.\r\nAdd a little oil and knead again until smooth.\r\nCover and let it rest for 15–20 minutes.\r\nMash boiled potatoes smoothly (no lumps).\r\nAdd onion, green chilies, cumin seeds, spices, coriander, and salt.\r\nMix everything well. Taste and adjust seasoning.\r\nDivide dough into equal balls.\r\nRoll one ball into a small circle.\r\nPlace 2–3 tbsp potato filling in the center.\r\nBring edges together and seal.\r\nGently flatten and roll into a 6–7 inch circle (dust with flour if needed).\r\nHeat a tawa (flat pan) on medium heat.\r\nPlace the rolled paratha on the hot pan.\r\nCook until bubbles appear, then flip.\r\nApply ghee/oil and cook both sides until golden brown spots appear.\r\nPress lightly with a spatula for even cooking.\r\n\r\n\r\n\r\n\r\n', 20, 34, 1, 'Medium', '20260303_225657_paratha.jpeg', 4, 7, '2026-03-03 17:26:58', '2026-03-05 04:19:45', 7, 'https://youtu.be/j1_05wNTUYY?si=xjLvCZsCb0bULzbW'),
(19, 'Chai Pakoda', 'Aloo Pakoda is a popular Indian tea-time snack made with thin potato slices dipped in spiced gram flour batter and deep-fried until golden and crispy. It is crunchy on the outside, soft inside, and tastes best with green chutney and hot chai.', '3–4 medium potatoes (thinly sliced)\r\n1 cup besan (gram flour)\r\n2 tbsp rice flour\r\n1 tsp red chili powder\r\n½ tsp turmeric powder\r\n½ tsp garam masala\r\n½ tsp ajwain\r\nSalt to taste\r\nA pinch of baking soda (optional)\r\nWater (as needed)\r\nOil for deep frying\r\n\r\n2 cups water\r\n1 cup milk\r\n2 tsp tea leaves (black tea)\r\n2–3 tsp sugar (adjust to taste)\r\n½ inch ginger (crushed)\r\n2 green cardamom (crushed)\r\nOptional: 1 small cinnamon stick or 1 clove', 'Peel and thinly slice potatoes.\r\nSoak in water for 5 minutes, then drain and dry.\r\nMix besan, rice flour, spices, salt, and ajwain.\r\nAdd water gradually to make a thick, smooth batter.\r\nAdd a pinch of baking soda and mix gently.\r\nHeat oil on medium flame.\r\nDip potato slices in batter and drop into hot oil.\r\nFry until golden and crispy.\r\nRemove and drain on tissue paper.\r\nIn a saucepan, add water, ginger, and cardamom.\r\nBoil for 2–3 minutes so spices release flavor.\r\nAdd tea leaves and boil for 1–2 minutes.\r\nPour in milk and add sugar.\r\nBoil on medium flame for 2–3 minutes.\r\nLet it rise once for strong flavor (watch carefully so it doesn’t spill).\r\nTurn off the flame.\r\nStrain into cups.\r\nServe hot ', 20, 29, 2, 'Medium', '20260303_232420_chai-pakoda.jpeg', 4, 7, '2026-03-03 17:54:20', '2026-03-05 04:18:34', 15, 'https://youtu.be/o9YraNho04A?si=fM0A5JzWxOxhbrdX'),
(20, 'Sev Puri', 'Sev Puri is a popular Indian street food made with crispy puris topped with boiled potatoes, onions, chutneys, and crunchy sev. It has a perfect combination of sweet, spicy, and tangy flavors, making it a delicious and refreshing snack.\r\n', 'Puri (crispy golgappa puris) – 20 pieces\r\n\r\nBoiled potatoes – 2 (finely chopped)\r\n\r\nOnion – 1 small (finely chopped)\r\n\r\nTomato – 1 small (finely chopped)\r\n\r\nSev – 1 cup\r\n\r\nSweet tamarind chutney – 3 tablespoons\r\n\r\nGreen chutney – 2 tablespoons\r\n\r\nChaat masala – 1 teaspoon\r\n\r\nRed chilli powder – ½ teaspoon\r\n\r\nSalt – to taste\r\n\r\nCoriander leaves – 2 tablespoons (chopped)\r\n\r\nLemon juice – 1 tablespoon', 'Boil and chop the potatoes.\r\n\r\n\r\nFinely chop onion, tomato, and coriander.\r\n\r\n\r\n Keep puris and chutneys ready.\r\n\r\n\r\n Arrange puris on a serving plate.\r\n\r\n\r\n Add a small amount of chopped potatoes on each puri.\r\n\r\n\r\nAdd onion and tomato pieces.\r\n\r\n\r\nPour a little green chutney and tamarind chutney on top.\r\n\r\n\r\nSprinkle chaat masala, red chilli powder, and salt.\r\n\r\n\r\n Top generously with sev.\r\n\r\n\r\nGarnish with coriander leaves and a few drops of lemon juice.', 15, 5, 1, 'Easy', '20260304_230739_savpuri.jpeg', 4, 12, '2026-03-04 17:37:39', '2026-03-08 15:26:07', 19, 'https://youtu.be/4ZRXAmKZ9ks?si=lmxZ0HhAx_Cyg3XC'),
(21, 'Samosa', 'samosa is a crispy, deep-fried pastry filled with a delicious mixture of spiced vegetables. Unlike the classic potato-only filling, this version includes mixed vegetables like carrots, beans, peas, and potatoes, making it more colorful and nutritious.', '2 cups all-purpose flour (maida)\r\n4 tablespoons oil or ghee\r\n½ teaspoon salt\r\n½ cup water (as needed)\r\n2 medium potatoes (boiled & cubed small)\r\n½ cup green peas\r\n¼ cup carrots (finely chopped)\r\n¼ cup French beans (finely chopped)\r\n¼ cup capsicum (optional)\r\n1 small onion (finely chopped, optional)\r\n1–2 green chilies (finely chopped)\r\n1 teaspoon ginger (grated)\r\n1 teaspoon cumin seeds\r\n1 teaspoon coriander powder\r\n½ teaspoon garam masala\r\n½ teaspoon red chili powder\r\n½ teaspoon turmeric powder\r\n1 teaspoon amchur (dry mango powder) or lemon juice\r\nSalt to taste\r\n2 tablespoons oil', 'Mix flour and salt in a bowl.\r\nAdd oil and rub well until crumbly.\r\nAdd water gradually and knead into a firm dough.\r\nCover and rest for 20–30 minutes.\r\nHeat oil in a pan.\r\nAdd cumin seeds and let them crackle.\r\nAdd ginger, green chilies, and onion. Sauté lightly.\r\nAdd carrots and beans first (as they take longer to cook).\r\nAdd peas and capsicum. Cook for 2–3 minutes.\r\nAdd potatoes and all spices.\r\nMix well and cook for 3–minutes.\r\nLet the mixture cool completely.\r\nDivide dough into small balls.\r\nRoll into oval shapes and cut in half.\r\nForm a cone with one half and seal with water.\r\nAdd vegetable filling.\r\nSeal the edges tightly.\r\nHeat oil on low-medium heat.\r\nFry samosas slowly until golden brown and crispy.\r\nRemove and drain on paper towel.', 20, 30, 2, 'Easy', '20260305_114115_samosa.jpeg', 5, 12, '2026-03-05 06:11:15', '2026-03-08 16:15:56', 4, 'https://youtu.be/hAYBfHeQmlA?si=P6WALjWTScByFQxH'),
(22, 'Dosa', 'Dosa is a thin, crispy South Indian crepe made from a fermented batter of rice and urad dal (black gram). It is light, crunchy on the outside, and soft inside. Dosa is commonly eaten for breakfast or dinner and served with coconut chutney and sambar.', '2 cups raw rice (or dosa rice)\r\n½ cup urad dal (split black gram, skinless)\r\n1 tablespoon chana dal (optional, for color)\r\n½ teaspoon fenugreek seeds (methi)\r\nSalt to taste\r\nWater as needed\r\n3 medium potatoes (boiled & mashed)\r\n1 medium onion (sliced thin)\r\n1–2 green chilies (chopped)\r\n1 teaspoon ginger (grated)\r\n½ teaspoon mustard seeds\r\n½ teaspoon cumin seeds\r\n8–10 curry leaves\r\n¼ teaspoon turmeric powder\r\nSalt to taste\r\n2 tablespoons oil\r\nFresh coriander leaves (chopped)', 'Wash rice and soak for 4–6 hours.\r\nWash urad dal, chana dal, and fenugreek seeds together and soak for 4–6 hours.\r\nGrind urad dal mixture first with little water until smooth and fluffy.\r\nGrind rice to a slightly grainy smooth paste.\r\nMix both batters in a large bowl.\r\nAdd salt lightly and mix well.\r\nCover and keep in a warm place for 8–12 hours.\r\nBatter should rise and become slightly bubbly.\r\nHeat a flat pan (tawa).\r\nLightly grease with oil.\r\nPour one ladle of batter in the center.\r\nSpread in circular motion to make a thin circle.\r\nDrizzle a little oil around edges.\r\nCook until golden and crispy.\r\nFold and serve.\r\nHeat oil in a pan.\r\nAdd mustard seeds, cumin, and curry leaves.\r\nAdd onions, green chilies, and ginger. Sauté.\r\nAdd turmeric and mashed potatoes.\r\nMix well and cook 2–3 minutes.\r\nPlace filling inside dosa and fold.', 30, 45, 2, 'Hard', '20260306_094012_dosa.jpeg', 5, 10, '2026-03-05 06:18:27', '2026-03-08 16:41:17', 6, 'https://youtu.be/g6lJiImhSCY?si=5wEIOxoWLCgVLhtu'),
(23, 'Motichoor Ladoo', 'Motichoor Ladoo is a popular Indian sweet made from tiny fried gram flour (besan) droplets called boondi, which are soaked in sugar syrup and shaped into soft, melt-in-the-mouth laddoos. It is commonly prepared during festivals, celebrations, and special occasions.', 'Besan (gram flour) – 1 cup\r\n\r\nWater – as needed (for batter)\r\n\r\nSugar – 1 cup\r\n\r\nWater – ½ cup (for syrup)\r\n\r\nCardamom powder – ¼ teaspoon\r\n\r\nOrange food color – a pinch (optional)\r\n\r\nGhee or oil – for deep frying\r\n\r\nChopped pistachios or almonds – 2 tablespoons\r\n\r\nMelon seeds or raisins – optional', 'Mix besan and water to make a smooth, slightly thin batter.\r\n\r\n\r\nAdd food color if using.\r\n\r\n\r\nPrepare sugar syrup by boiling sugar and water until slightly sticky.\r\n\r\n\r\nAdd cardamom powder to the syrup.\r\n\r\n Heat ghee or oil in a deep pan.\r\n\r\n Pour batter through a perforated ladle (boondi jhara) into hot oil to make tiny boondi.\r\n\r\n Fry lightly for a few seconds (do not make them too crispy).\r\n\r\n Remove and immediately add the hot boondi to the warm sugar syrup.\r\n\r\n Mix well and add chopped dry fruits.\r\n\r\n Let the mixture cool slightly.\r\n\r\nTake small portions and shape them into round laddoos.', 20, 25, 2, 'Medium', '20260306_093213_laddu.jpeg', 3, 11, '2026-03-06 04:00:51', '2026-03-08 16:14:37', 6, 'https://youtu.be/s1QxpXVdvCw?si=hVdyIEQoOqdZ-Qv0'),
(24, ' Ras Malai', 'Ras Malai is a famous Indian dessert made from soft paneer (chhena) balls soaked in sweet, thickened milk flavored with cardamom and saffron. It has a rich, creamy texture and is often garnished with pistachios or almonds. Ras Malai is commonly served chilled during festivals and special occasions.\r\n', 'Milk – 1 liter\r\n\r\nLemon juice or vinegar – 2 tablespoons\r\n\r\nWater – 4 cups\r\n\r\nSugar – 1 cup\r\n\r\nMilk – 500 ml\r\n\r\nSugar – 4 tablespoons\r\n\r\nCardamom powder – ¼ teaspoon\r\n\r\nSaffron strands – a few (optional)\r\n\r\nChopped pistachios or almonds – 2 tablespoons', 'Boil milk and add lemon juice to curdle it.\r\n\r\nStrain the curdled milk using a cloth to get paneer (chhena).\r\n\r\nWash with cold water to remove sour taste.\r\n\r\nSqueeze excess water and knead the paneer until smooth.\r\n\r\nMake small smooth balls from the kneaded paneer.\r\n\r\nBoil water and sugar in a pan to make sugar syrup.\r\n\r\nAdd paneer balls and cook for 10–12 minutes until they expand.\r\n\r\nIn another pan, boil milk and cook until it thickens slightly.\r\n\r\nAdd sugar, cardamom powder, and saffron to the milk.\r\n\r\nSqueeze sugar syrup from the cooked paneer balls and place them in the thickened milk.\r\n\r\nCook for 5 minutes and add chopped nuts.', 25, 35, 2, 'Hard', '20260310_094501_rassmalai.jpeg', 6, 11, '2026-03-06 04:16:47', '2026-03-10 04:15:13', 8, 'https://youtu.be/5cLdNM6xH7s?si=dGLQzW8iv_uLKbYF'),
(25, 'Puri & Aloo Sabji', 'Puri and Aloo Sabji is a popular Indian meal where deep-fried fluffy bread (puri) is served with spicy potato curry (aloo sabji). It is commonly eaten for breakfast, festivals, or special occasions and has a delicious combination of crispy puris and flavorful potato gravy.', 'Wheat flour (atta) – 2 cups\r\n\r\nSalt – ½ teaspoon\r\n\r\nOil – 1 tablespoon\r\n\r\nWater – as needed\r\n\r\nOil – for deep frying\r\n\r\nPotatoes – 3–4 (boiled and chopped)\r\n\r\nOil – 2 tablespoons\r\n\r\nCumin seeds – 1 teaspoon\r\n\r\nGreen chilli – 1 (chopped)\r\n\r\nTomato – 1 (chopped)\r\n\r\nTurmeric powder – ¼ teaspoon\r\n\r\nRed chilli powder – ½ teaspoon\r\n\r\nCoriander powder – 1 teaspoon\r\n\r\nSalt – to taste\r\n\r\nWater – 1 cup\r\n\r\nCoriander leaves – for garnish', 'In a bowl, mix wheat flour, salt, and oil.\r\n\r\nAdd water and knead into a stiff dough.\r\n\r\nCover and rest for 10–15 minutes.\r\n\r\nMake small balls and roll them into small circles.\r\n\r\nHeat oil in a pan.\r\n\r\nFry the puris until they puff up and turn golden.\r\n\r\nRemove and keep on tissue paper.\r\n\r\n Heat oil in a pan and add cumin seeds.\r\n\r\nAdd green chilli and chopped tomatoes. Cook for 2 minutes.\r\n\r\nAdd turmeric, red chilli powder, coriander powder, and salt.\r\n\r\nAdd boiled potatoes and mix well.\r\n\r\nPour water and cook for 5–7 minutes until slightly thick.\r\n\r\nGarnish with coriander leaves.', 20, 25, 3, 'Medium', '20260310_102401_puri-shak.jpeg', 6, 9, '2026-03-06 04:27:18', '2026-03-10 04:54:01', 9, 'https://youtu.be/smdOXayg33M?si=xkbBcnIycCmrtUVz'),
(26, 'Pav Bhaji', 'Pav Bhaji is a famous Indian street food made with a spicy mashed vegetable curry (bhaji) served with soft butter-toasted bread rolls (pav). It has a rich, tangy, and buttery flavor and is commonly enjoyed as a snack or light meal.\r\n', 'Potatoes – 3 (boiled and mashed)\r\n\r\nCauliflower – 1 cup (chopped)\r\n\r\nGreen peas – ½ cup\r\n\r\nCapsicum – 1 (finely chopped)\r\n\r\nOnion – 1 large (chopped)\r\n\r\nTomato – 2 (chopped)\r\n\r\nGinger-garlic paste – 1 tablespoon\r\n\r\nPav bhaji masala – 2 teaspoons\r\n\r\nTurmeric powder – ¼ teaspoon\r\n\r\nRed chilli powder – ½ teaspoon\r\n\r\nButter – 2 tablespoons\r\n\r\nSalt – to taste\r\n\r\nWater – as needed\r\n\r\nCoriander leaves – for garnish\r\n\r\nPav (bread rolls) – 6\r\n\r\nButter – 2 tablespoons\r\n\r\n', 'Heat butter in a pan and add chopped onions. Sauté until golden.\r\n\r\nAdd ginger-garlic paste and cook for a minute.\r\n\r\nAdd tomatoes and cook until soft.\r\n\r\nAdd turmeric, red chilli powder, pav bhaji masala, and salt.\r\n\r\nAdd mashed vegetables and mix well.\r\n\r\nAdd a little water and mash everything together while cooking for 5–7 minutes.\r\n\r\n Garnish with coriander leaves.\r\n\r\nCut pav in half.\r\n\r\nHeat butter on a pan and toast the pav until golden.', 25, 35, 2, 'Medium', '20260310_092652_pav-bhaji.jpeg', 6, 10, '2026-03-06 04:31:37', '2026-03-10 03:56:53', 6, 'https://youtu.be/qMAYG-soxhw?si=qhlMq4rMP5MVTqgL'),
(27, 'Street Style Bhel ', 'Street Style Bhel is a popular Indian street snack made by mixing puffed rice with chopped vegetables, tangy tamarind chutney, spicy green chutney, and crunchy sev. It has a perfect balance of sweet, spicy, and tangy flavors with a crispy texture, making it a refreshing and quick snack.\r\n', 'Puffed rice (murmura) – 2 cups\r\n\r\nOnion – 1 small (finely chopped)\r\n\r\nTomato – 1 small (finely chopped)\r\n\r\nBoiled potato – 1 (chopped)\r\n\r\nGreen chilli – 1 (finely chopped)\r\n\r\nRoasted peanuts – 2 tablespoons\r\n\r\nSweet tamarind chutney – 2 tablespoons\r\n\r\nGreen chutney – 1 tablespoon\r\n\r\nChaat masala – 1 teaspoon\r\n\r\nRed chilli powder – ½ teaspoon\r\n\r\nSalt – to taste\r\n\r\nSev – ½ cup\r\n\r\nCoriander leaves – 2 tablespoons (chopped)\r\n\r\nLemon juice – 1 tablespoon', 'Chop onion, tomato, green chilli, and coriander leaves.\r\n\r\nBoil and chop the potato.\r\n\r\nKeep all ingredients ready for mixing.\r\n\r\nIn a large bowl, add puffed rice.\r\n\r\nAdd chopped onion, tomato, potato, and peanuts.\r\n\r\nAdd green chutney and tamarind chutney.\r\n\r\nSprinkle chaat masala, red chilli powder, and salt.\r\n\r\nAdd lemon juice and mix everything quickly.\r\n\r\nTop with sev and coriander leaves.', 20, 15, 1, 'Easy', '20260310_102050_bhel.jpeg', 6, 12, '2026-03-06 05:19:16', '2026-03-10 04:50:50', 10, 'https://youtu.be/2KHWy7sCaVk?si=gGcOHBgvPGQG6jCe'),
(28, 'Gulab Jamun', 'Gulab Jamun is a very popular sweet dessert from India. It is made from milk solids (khoya or milk powder), shaped into small balls, deep-fried until golden brown, and soaked in a fragrant sugar syrup flavored with cardamom and rose water. It is soft, juicy, and usually served warm during festivals and celebrations like Diwali and Holi.', '1 cup milk powder\r\n\r\n¼ cup all-purpose flour (maida)\r\n\r\n2 tbsp ghee (clarified butter)\r\n\r\n½ tsp baking powder\r\n\r\n¼ cup milk (for kneading)\r\n\r\n1½ cups sugar\r\n\r\n1½ cups water\r\n\r\n3–4 cardamom pods\r\n\r\n1 tsp rose water (optional)\r\n\r\nFew saffron strands (optional)\r\n\r\nOil or ghee (enough for deep frying)', 'Take a pan and add sugar and water.\r\n\r\nHeat it and stir until the sugar dissolves.\r\n\r\nAdd cardamom pods and saffron.\r\n\r\nSimmer for about 5 minutes.\r\n\r\nTurn off the heat and add rose water.\r\n\r\nKeep the syrup warm.\r\n\r\nIn a bowl, mix milk powder, flour, and baking powder.\r\n\r\nAdd ghee and mix well.\r\n\r\nSlowly add milk and knead into a soft dough.\r\n\r\nDo not over-knead.\r\n\r\nDivide the dough into small equal portions.\r\n\r\nRoll each portion into smooth balls.\r\n\r\nMake sure there are no cracks.\r\n\r\nHeat oil or ghee on low to medium heat in a deep pan.\r\n\r\nOil should not be too hot.\r\n\r\n\r\nAdd the dough balls gently into the oil.\r\n\r\nFry slowly while stirring gently.\r\n\r\nCook until they turn golden brown.\r\n\r\nRemove the fried jamuns from oil.\r\n\r\nImmediately place them into the warm sugar syrup.\r\n\r\nLet them soak for 1–2 hours so they become soft and juicy.\r\n', 20, 30, 2, 'Medium', '20260310_094742_gulabjambu.jpeg', 6, 11, '2026-03-08 15:47:20', '2026-03-10 04:17:43', 11, 'https://youtu.be/J3O0ZEJYLFQ?si=WA9nerwp-17bf8pu'),
(29, 'Thepla ', 'Thepla is a popular Gujarati flatbread made with wheat flour, spices, and sometimes fenugreek leaves (methi). It is soft, flavorful, and usually eaten for breakfast, lunch, or while traveling. It tastes best with dahi (yogurt) and pickle.', '2 cups whole wheat flour\r\n\r\n1 cup chopped fenugreek leaves (methi)\r\n\r\n2 tablespoons yogurt (dahi)\r\n\r\n1 teaspoon turmeric powder\r\n\r\n1 teaspoon red chili powder\r\n\r\n1 teaspoon cumin seeds\r\n\r\n½ teaspoon salt\r\n\r\n1 teaspoon ginger-green chili paste\r\n\r\n1 tablespoon oil\r\n\r\nWater (as needed)\r\n\r\n oil or ghee', 'Take a large bowl and add wheat flour and chopped methi leaves.\r\n\r\nAdd turmeric powder, red chili powder, cumin seeds, salt, ginger-chili paste, yogurt, and oil.\r\n\r\nMix everything well.\r\n\r\nAdd a little water slowly.\r\n\r\nKnead into a soft dough.\r\n\r\nCover the dough and let it rest for 10–15 minutes.\r\n\r\nDivide the dough into small lemon-size balls.\r\n\r\nRoll each ball lightly in dry flour.\r\n\r\nUse a rolling pin to roll each ball into a thin round flatbread.\r\n\r\nHeat a tawa (flat pan) on medium heat.\r\n\r\nPlace the rolled thepla on the hot pan.\r\n\r\nCook one side for about 30 seconds.\r\n\r\nFlip it and apply a little oil.\r\n\r\nCook both sides until golden spots appear.', 10, 25, 1, 'Medium', '20260310_101642_theplaa.jpg', 7, 7, '2026-03-08 15:54:24', '2026-03-10 04:46:42', 7, 'https://youtu.be/iPO-8KVOpvg?si=BWYWr2QF_wZPZKPR'),
(30, 'Chole Bhature', 'Chole Bhature is a famous North Indian dish made with spicy chickpea curry (chole) served with deep-fried fluffy bread (bhature). It is a popular breakfast and street food, especially in cities like Delhi. The dish is rich, flavorful, and often served with onion, pickle, and yogurt.', '1 cup chickpeas (chole), soaked overnight\r\n\r\n2 tablespoons oil\r\n\r\n1 onion (finely chopped)\r\n\r\n2 tomatoes (pureed)\r\n\r\n1 teaspoon ginger-garlic paste\r\n\r\n1 teaspoon cumin seeds\r\n\r\n1 teaspoon coriander powder\r\n\r\n½ teaspoon turmeric powder\r\n\r\n1 teaspoon red chili powder\r\n\r\n1 teaspoon garam masala\r\n\r\nSalt to taste\r\n\r\nFresh coriander leaves (for garnish)\r\n\r\n2 cups water\r\n\r\n2 cups all-purpose flour (maida)\r\n\r\n2 tablespoons semolina (sooji)\r\n\r\n½ cup yogurt (curd)\r\n\r\n½ teaspoon baking powder\r\n\r\n½ teaspoon salt\r\n\r\n1 teaspoon sugar\r\n\r\nWater (as needed)\r\n\r\nOil for deep frying', 'Wash the soaked chickpeas.\r\n\r\nPut them in a pressure cooker with water and salt.\r\n\r\nCook for about 15–20 minutes until soft.\r\n\r\nHeat oil in a pan.\r\n\r\nAdd cumin seeds and let them crackle.\r\n\r\nAdd chopped onion and sauté until golden brown.\r\n\r\nAdd ginger-garlic paste and cook for 1 minute.\r\n\r\nAdd tomato puree and cook until oil separates.\r\n\r\nAdd turmeric, red chili powder, coriander powder, and salt.\r\n\r\nMix well and cook for 2–3 minutes.\r\n\r\nAdd the boiled chickpeas and some cooking water.\r\n\r\nMix well and simmer for 10–15 minutes.\r\n\r\nSprinkle garam masala and garnish with coriander leaves.\r\n\r\nIn a bowl mix flour, semolina, salt, sugar, and baking powder.\r\n\r\nAdd yogurt and mix.\r\n\r\nAdd water slowly and knead into a soft dough.\r\n\r\nCover and rest for 20 minutes.\r\n\r\nDivide dough into small balls.\r\n\r\nRoll each ball into an oval or round shape.\r\n\r\nHeat oil in a deep pan.\r\n\r\nCarefully put rolled dough into hot oil.\r\n\r\nPress lightly so it puffs up.\r\n\r\nFry until golden brown on both sides.', 30, 40, 2, 'Hard', '20260308_221922_chole.jpeg', 5, 10, '2026-03-08 16:49:22', '2026-03-10 04:49:41', 9, 'https://youtu.be/QbyXsYOTJD4?si=PvwNJaGouPeadyV4'),
(31, 'Vada Pav', 'Vada Pav is one of the most famous street foods from Mumbai. It consists of a spicy potato fritter (batata vada) placed inside a soft bread bun called pav, served with chutneys and fried green chili. It is often called the Indian burger.', '3 boiled potatoes (mashed)\r\n\r\n1 tablespoon oil\r\n\r\n1 teaspoon mustard seeds\r\n\r\n1 teaspoon cumin seeds\r\n\r\n1 teaspoon ginger-garlic paste\r\n\r\n1–2 chopped green chilies\r\n\r\n½ teaspoon turmeric powder\r\n\r\nSalt to taste\r\n\r\n2 tablespoons chopped coriander leaves\r\n\r\n1 cup gram flour (besan)\r\n\r\n½ teaspoon turmeric powder\r\n\r\n½ teaspoon red chili powder\r\n\r\nSalt to taste\r\n\r\nWater (to make smooth batter)\r\n', 'Heat oil in a pan.\r\n\r\nAdd mustard seeds and cumin seeds and let them crackle.\r\n\r\nAdd ginger-garlic paste and chopped green chilies.\r\n\r\nAdd turmeric powder and mashed potatoes.\r\n\r\nAdd salt and mix well.\r\n\r\nAdd coriander leaves and cook for 2–3 minutes.\r\n\r\nLet the mixture cool and make small balls.\r\n\r\nIn a bowl mix gram flour, turmeric powder, chili powder, and salt.\r\n\r\nAdd water slowly and mix to make a thick smooth batter.\r\n\r\nHeat oil in a deep pan.\r\n\r\nDip each potato ball into the batter.\r\n\r\nCarefully drop it into hot oil.\r\n\r\nFry until golden brown and crispy.\r\n\r\nSlice the pav buns in the middle.\r\n\r\nSpread garlic chutney or green chutney inside.\r\n\r\nPlace one hot batata vada inside the pav.\r\n\r\nPress lightly.\r\n\r\nServe with fried green chilies.\r\n', 25, 20, 1, 'Easy', '20260310_101807_vadapav.jpeg', 7, 12, '2026-03-08 16:55:39', '2026-03-10 04:54:38', 8, 'https://youtu.be/bhE1_h4liH0?si=inxTuXz_j-tneNOk'),
(32, 'Paneer Masala with Naan', 'Paneer Masala with Naan is a classic North Indian dish. Paneer (Indian cottage cheese) cubes are simmered in a creamy tomato-based gravy flavored with spices like turmeric, cumin, garam masala, and ginger-garlic. It is commonly served with naan, a soft flatbread cooked in a hot skillet or tandoor. The dish is rich, aromatic, and perfect for lunch or dinner.', '250 g paneer (cut into cubes)\r\n\r\n2 tablespoons oil or butter\r\n\r\n1 medium onion (finely chopped)\r\n\r\n2 tomatoes (pureed)\r\n\r\n1 teaspoon ginger-garlic paste\r\n\r\n½ teaspoon turmeric powder\r\n\r\n1 teaspoon red chili powder\r\n\r\n1 teaspoon cumin powder\r\n\r\n1 teaspoon coriander powder\r\n\r\n½ teaspoon garam masala\r\n\r\n½ cup cream or milk (optional for richness)\r\n\r\n½ teaspoon salt (or to taste)\r\n\r\n½ cup water\r\n\r\n2 tablespoons chopped fresh cilantro (coriander leaves)\r\n\r\n2 cups all-purpose flour\r\n\r\n½ teaspoon salt\r\n\r\n½ teaspoon sugar\r\n\r\n1 teaspoon baking powder\r\n\r\n2 tablespoons yogurt\r\n\r\n¾ cup warm water\r\n\r\n1 tablespoon oil or melted butter\r\n\r\nExtra butter for brushing', 'Cut paneer into medium cubes.\r\n\r\nOptional: Lightly pan-fry the cubes in a little oil until golden. Set aside.\r\n\r\nHeat oil or butter in a pan on medium heat.\r\n\r\nAdd chopped onions and sauté until golden brown.\r\n\r\nAdd ginger-garlic paste and cook for 1 minute.\r\n\r\nPour in the tomato puree and cook until the oil starts separating.\r\n\r\nAdd turmeric, chili powder, cumin powder, coriander powder, and salt.\r\n\r\nCook the mixture for 2–3 minutes.\r\n\r\nAdd the paneer cubes to the gravy.\r\n\r\nPour in water and simmer for about 5–7 minutes.\r\n\r\nStir in cream or milk for a rich texture.\r\n\r\nSprinkle garam masala and chopped cilantro.\r\n\r\nTurn off heat.\r\n\r\nIn a bowl, mix flour, salt, sugar, and baking powder.\r\n\r\nAdd yogurt and warm water to form a soft dough.\r\n\r\nKnead for 5 minutes, cover, and rest for 30 minutes.\r\n\r\nDivide dough into small balls and roll into oval shapes.\r\n\r\nCook each naan on a hot skillet until bubbles form and brown spots appear.\r\n\r\nBrush with butter.', 25, 35, 3, 'Hard', '20260310_100105_panjabi.jpeg', 2, 10, '2026-03-10 04:31:05', '2026-03-10 04:31:22', 1, 'https://youtu.be/rkMzLvcy-JY?si=njcpIt-rJlRsfh98');

-- --------------------------------------------------------

--
-- Table structure for table `recipe_favorites`
--

CREATE TABLE `recipe_favorites` (
  `id` int(11) NOT NULL,
  `recipe_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recipe_favorites`
--

INSERT INTO `recipe_favorites` (`id`, `recipe_id`, `user_id`, `created_at`) VALUES
(8, 13, 2, '2026-02-18 03:55:59'),
(12, 16, 1, '2026-02-18 15:24:06'),
(13, 8, 1, '2026-02-19 11:48:11'),
(14, 17, 3, '2026-03-06 04:08:27'),
(15, 30, 7, '2026-03-08 16:58:11'),
(16, 27, 6, '2026-03-10 04:19:29');

-- --------------------------------------------------------

--
-- Table structure for table `recipe_ratings`
--

CREATE TABLE `recipe_ratings` (
  `id` int(11) NOT NULL,
  `recipe_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `rating` int(11) DEFAULT NULL CHECK (`rating` >= 1 and `rating` <= 5),
  `review` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `author_reply` text DEFAULT NULL,
  `replied_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `recipe_ratings`
--

INSERT INTO `recipe_ratings` (`id`, `recipe_id`, `user_id`, `rating`, `review`, `created_at`, `author_reply`, `replied_at`) VALUES
(19, 14, 1, 4, 'Great & easy recipe, really enjoyed it.', '2026-02-18 15:19:44', NULL, NULL),
(23, 15, 1, 3, '', '2026-02-18 16:38:53', NULL, NULL),
(24, 16, 1, 4, '', '2026-02-18 16:39:08', NULL, NULL),
(26, 8, 2, 3, '', '2026-02-19 03:43:00', NULL, NULL),
(28, 12, 1, 5, 'Great Recipe, thank you!', '2026-02-19 11:42:28', NULL, NULL),
(30, 21, 3, 5, 'Wow, this is absolutely delicious!❤️', '2026-03-06 04:04:58', NULL, NULL),
(32, 20, 3, 4, 'I made this for my father,he is so happy after eating😊', '2026-03-06 04:07:08', NULL, NULL),
(33, 17, 3, 5, '', '2026-03-06 04:08:06', NULL, NULL),
(34, 30, 7, 5, 'This chole bhature\'s recipe is delicious,my child love it! ', '2026-03-08 16:59:46', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `bio` text DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `email`, `password_hash`, `first_name`, `last_name`, `bio`, `profile_image`, `created_at`, `updated_at`) VALUES
(1, 'Palak', 'palakkanani@gmail.com', 'pbkdf2:sha256:600000$rs8k51pwC8QRXwhz$141f27ef56f4aaa80b16a1ac1d3482c36c295770f3a0489f4acb8ac607dfdd5d', 'Palak', 'Kanani', NULL, NULL, '2026-01-30 15:04:58', '2026-01-30 15:04:58'),
(2, 'Nena ', 'nena@gmail.com', 'scrypt:32768:8:1$OHp50AD3OKAV1VNW$abc939d8def11fe62e98b32dd190bae53a0ef7834e68fc738eda6b28042a5d3f7747a2e1a5f753dfccee40c2cd3c85d35a14fa00540e7432aa86370201be395d', 'nena', 'lila', NULL, NULL, '2026-02-01 11:42:57', '2026-02-02 08:44:57'),
(3, 'mahek', 'mahi@gmail.com', 'scrypt:32768:8:1$HQRl1kry5ChfPINY$acdc6e7f931e58e5c4830d59a393b865274a42f7cb846bba8c67370c7770f64eef7e5e11fd8c2a244d50692d1ae267fd433c56b4111aa5e7f857ec4efe4ae352', '', '', NULL, NULL, '2026-02-04 09:36:17', '2026-02-04 09:36:17'),
(4, 'kinju', 'kinju12@gmail.com', 'scrypt:32768:8:1$f8IufRFuJkYK3ZPc$ed23616d79084d4c08c6b6bd818792f3e2b8dbd1dcf2060428321e03a9048daf2437e2c862e328e742b78bb74d3170fa6ff42c283263b18b12a0618f077a0d1b', 'kinjal', 'kathrecha', NULL, NULL, '2026-03-03 17:16:13', '2026-03-03 17:16:13'),
(5, 'janvi', 'janvi@gmail.com', 'scrypt:32768:8:1$Rk55PxjRPjpTAhUt$ef927ce5106ddfa7d178c22d8b5d63b6b2accf5caf3027107676fe96d8fcc14453217460f0926adf3626e1c391b47ee93a0dc2453cc4a5d06b6673bddcc2c4e5', 'Janvi', 'sharma', NULL, NULL, '2026-03-05 05:47:11', '2026-03-05 05:47:11'),
(6, 'ariya', 'ariya@gmail.com', 'scrypt:32768:8:1$mGpWqXdtZ2dtpKo3$35b279e1b8b59b2a725042c82f549b9678e0997118f47984a9781ef67fe943712f291397d078f840a0c6f7d998e209f5f240018724ee8431b19977ad5c5e3125', 'Ariya', 'Khanna', NULL, NULL, '2026-03-06 04:11:35', '2026-03-06 04:11:35'),
(7, 'trusha', 'trusha12@gmail.com', 'scrypt:32768:8:1$ooELUEsXi9e0z5oF$419e0d54e4b4569140c5843188a7d70b1a0940d210b8c276506d3714b7b1dd5f864e02c4eec9efe11b3eb150351de47e93e657013894af26e56aa9014ce254a2', 'Trusha', 'kher', NULL, NULL, '2026-03-08 15:50:54', '2026-03-08 15:50:54');

-- --------------------------------------------------------

--
-- Table structure for table `user_follows`
--

CREATE TABLE `user_follows` (
  `id` int(11) NOT NULL,
  `follower_id` int(11) NOT NULL,
  `followed_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_follows`
--

INSERT INTO `user_follows` (`id`, `follower_id`, `followed_id`, `created_at`) VALUES
(1, 1, 2, '2026-02-18 13:35:19'),
(2, 2, 3, '2026-02-19 03:42:41'),
(3, 1, 5, '2026-03-08 16:42:25'),
(4, 7, 5, '2026-03-08 17:00:06'),
(5, 6, 7, '2026-03-10 04:55:27');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `contact_queries`
--
ALTER TABLE `contact_queries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `recipes`
--
ALTER TABLE `recipes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `recipe_favorites`
--
ALTER TABLE `recipe_favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_recipe_user` (`recipe_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `recipe_ratings`
--
ALTER TABLE `recipe_ratings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_recipe_user` (`recipe_id`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `user_follows`
--
ALTER TABLE `user_follows`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_follow` (`follower_id`,`followed_id`),
  ADD KEY `followed_id` (`followed_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `contact_queries`
--
ALTER TABLE `contact_queries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `recipes`
--
ALTER TABLE `recipes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `recipe_favorites`
--
ALTER TABLE `recipe_favorites`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `recipe_ratings`
--
ALTER TABLE `recipe_ratings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `user_follows`
--
ALTER TABLE `user_follows`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `recipes`
--
ALTER TABLE `recipes`
  ADD CONSTRAINT `recipes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recipes_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`);

--
-- Constraints for table `recipe_favorites`
--
ALTER TABLE `recipe_favorites`
  ADD CONSTRAINT `recipe_favorites_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recipe_favorites_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `recipe_ratings`
--
ALTER TABLE `recipe_ratings`
  ADD CONSTRAINT `recipe_ratings_ibfk_1` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `recipe_ratings_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `user_follows`
--
ALTER TABLE `user_follows`
  ADD CONSTRAINT `user_follows_ibfk_1` FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `user_follows_ibfk_2` FOREIGN KEY (`followed_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
