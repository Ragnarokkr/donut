== #emoji.notepad Terminology <terminology>

This system uses *donuts* as a central metaphor. Why donuts?
Well, who doesn't love donuts! I mean, even many famous Blender 3D artists
started with the well known #link("https://www.youtube.com/playlist?list=PLjEaoINr3zgGUwGwXlj9kBe7TrVWNjkyv")[donut tutorial]!

- *Glaze*: A Nushell script located in the `glazes/` directory. It manages a
  module's manifest, installation, and configuration. It is the core logic
  provided by the user.
- *Topping*: An individual program installed by a Glaze. A Glaze generally
  includes one Topping for custom installation or configuration. When no
  specific setup is required, multiple Toppings can be logically grouped
  (e.g., a "cli-tools" glaze might contain several command-line programs).
