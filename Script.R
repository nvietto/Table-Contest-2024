
# Load 📦 ---------------------------------------------------------------------

pacman::p_load(gt, gtExtras, janitor, tidyverse, readxl)

data <- read_excel("data.xlsx")

# Wrangle ---------------------------------------------------------------------

data <- data |> 
  clean_names() |> 
  as_tibble() |> 
  arrange(actual) |> 
  mutate(across(5:9, as.numeric)) |> 
  mutate(across(everything(), ~ ifelse(is.na(.), 0, .))) |> 
  pivot_longer(cols = -c(players, actual_1, who_was_correct, mean_projection),
               names_to = 'draft',
               values_to = 'position') |>
  group_by(players, actual_1, who_was_correct, mean_projection) |> 
  summarise(positions = list(position)) |> 
  ungroup() |> 
  mutate(mean_projection = as.numeric(mean_projection)) |> 
  mutate(mean_projection_1 = mean_projection) |> 
  mutate(change_score = abs(mean_projection_1 - actual_1)) |> 
  select(players, mean_projection, actual_1, change_score, positions, who_was_correct)


color_palette <- c("#3B9AB2", "#F21A00", "#FF0000")

# Table 📈 ---------------------------------------------------------------------
                                                   
data |> 
  arrange(actual_1) |> 
  gt() |> 
  tab_header(
    title = md('**All Mocks are Wrong, but Some are Useful**'),
    subtitle = md('*The final 2024 `NFL` Mock Drafts from Daniel Jeremiah (DJ), Peter Schrager (PS), Mel Kiper (MK), Bucky Brooks (BB)*')) |> 
  tab_options(
    heading.align = "Center",
    heading.title.font.size = px(24),
    heading.background.color = "#5BBCD6") |> 
  opt_table_font(font = google_font(name = "Playfair Display")) |> 
  cols_label(
    players = 'Player Name',
    actual_1 = 'Actual Draft Position',
    change_score = 'Difference',
    who_was_correct = 'Who Predicted Correctly',
    mean_projection = 'Average Projected Draft Position',
    positions = md('Projected Position <br> (DJ, PS, MK, BB, Actual)'), 
  ) |> 
  gt_plt_sparkline(column = positions, palette = c("#FF0000", "#00A08A", "#F2AD00", "#F98400", "#5BBCD6"))|> 
  gt_color_rows(
    columns = c(actual_1, mean_projection),
    domain = c(0, 100),
    palette = color_palette) |> 
  opt_stylize(style = 6) |> 
  gt_plt_bar_pct(change_score, fill="#5BBCD6", scaled = FALSE) |> 
  cols_align(align = "center", columns = c(mean_projection, actual_1, change_score)) |> 
  tab_source_note(source_note = ("Data: NFL.com and Sharp Football | Table created by Nicholas Vietto for the 2024 Posit Table Contest"))




