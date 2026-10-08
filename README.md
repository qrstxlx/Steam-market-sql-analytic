# What Makes a Game Win on Steam? (SQL Analysis)

I wanted to dive into real gamer data to see how pricing, player reviews, and genres actually interact on Steam. Using a dataset of over 27,000 games, I wrote PostgreSQL queries to uncover what separates quick cash grabs from games that build massive, dedicated fanbases.

---

## The Questions I Wanted to Answer
1. **Which games are truly loved by the community?** (Filtering out weird games with 3 reviews and a 100% rating).
2. **Does price change how long people play?** Are players sticking around for expensive titles, or do Free-to-Play games win on pure retention?
3. **Who dominates each genre?** Using window functions to pull out the most-played titles per category.

---

## Tech I Used
- **PostgreSQL 18** via **pgAdmin 4**
- **Core SQL features:**
  - `CASE WHEN` for breaking games into realistic price brackets.
  - Aggregations with `ROUND` and `NULLIF` (to avoid painful division-by-zero errors).
  - `string_to_array` + `UNNEST` to unpack games tagged with multiple genres.
  - `DENSE_RANK() OVER (PARTITION BY ... ORDER BY ...)` for ranking titles inside their own genre silos.

---

## What the Data Actually Showed

### 1. The True Community Favorites
When you set a solid threshold (at least 10,000 player reviews), niche noise disappears and legendary titles shine through:
- **`Portal 2`** takes the crown with a mind-blowing **98.65%** positive rating across 140,000+ reviews.
- **`Factorio`** comes right behind at **98.51%** — proof that deep, addictive gameplay beats fancy graphics.
- **`The Witcher 3: Wild Hunt`** stands out for pure scale: maintaining a **97.69%** approval rating across more than **207,000 reviews** is insane consistency.

### 2. Pricing vs. How Much People Play
I grouped games into 4 tiers (Free-to-Play, Under $10, $10–$30, and $30+) and found a very clear pattern:
- **Players put their time where their money is:** Premium games ($30+) average **1,229 minutes (~20.5 hours)** of playtime, blowing budget games out of the water.
- **The Indie Sweet Spot ($10–$30):** Games in this middle tier hit the highest average approval rate (**75.68%**). Players feel they get great value without the bugs or corporate hype of some AAA releases.
- **The Budget Graveyard:** Nearly 20,000 games sit in the under-$10 tier, but their average playtime is just 68 minutes — lots of impulse buys that get abandoned fast.

### 3. Genre Champions
Breaking out multi-genre strings showed that complex strategy, RPG, and survival titles easily pull off thousands of hours of playtime, while standard action games drop off much faster once the main campaign ends.

---

## Files in This Repo
- `steam_analysis_queries.sql` — clean SQL queries with comments explaining the logic step-by-step.
- `results/` — exported CSV files with raw query outputs.

---

## How to Run It
1. Clone this repository.
2. Grab `steam.csv` from Kaggle (Steam Store Games dataset).
3. Run the script in **pgAdmin 4** or straight from `psql` to create the table, import the CSV, and run the queries.
