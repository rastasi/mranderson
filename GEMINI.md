# TIC-80 Lua Code Regularities

Based on the analysis of `mranderson.lua`, the following regularities and conventions should be followed for future modifications and development within this project:

## General Structure & Lifecycle

1.  **TIC-80 Game Loop:** All primary game logic, updates, and rendering should be encapsulated within the `TIC()` function, which serves as the main entry point for each frame of the TIC-80 game cycle.
2.  **Initialization:** Game state variables and one-time setup should occur at the global scope or within a dedicated initialization function called once.

## Naming Conventions

3.  **Functions:** Custom function names should use `PascalCase` (e.g., `UpdatePlayer`, `DrawHUD`). Existing mathematical helper functions like `SQR()` are an exception.
4.  **Variables:** Variables should use `snake_case` (e.g., `player_x`, `game_state`), aligning with the existing `flip_x` variable.
5.  **Constants:** Constants should be named using `SCREAMING_SNAKE_CASE` (e.g., `MAX_SPEED`, `GRAVITY_STRENGTH`).

## Variable Handling & Grouping

6.  **Global Variables:** Major game state variables (e.g., position, velocity, animation frames) are typically defined at the global scope for easy access throughout the game loop.
7.  **Lua Tables for Grouping:** Collections of related data should be grouped into Lua tables for better organization and readability (e.g., `player = {x = 0, y = 0, speed = 1}`).
8.  **Table Formatting:** Tables with multiple elements or complex structures should always be defined with line breaks for each key-value pair, rather than inline, to improve readability.
    Example:
    ```lua
    my_table = {
      key1 = value1,
      key2 = value2,
    }
    ```
    instead of `my_table = {key1 = value1, key2 = value2}`.

## Functions

9.  **Helper Functions:** Reusable logic or common calculations should be extracted into separate, clearly named helper functions.

## Input Handling

10. **`btn()` for Input:** User input should be handled primarily through the TIC-80 `btn()` function, checking for specific button presses or states.

## Graphics & Rendering

11. **`spr()` for Sprites:** Individual sprites should be rendered using the `spr()` function.
12. **`map()` for Maps:** Tilemaps should be drawn using the `map()` function.
13. **`print()` for Text:** Text display should utilize the `print()` function.

## Code Style

14. **Indentation:** Use consistent indentation, likely 2 spaces, for code blocks to enhance readability.
15. **Comments:** Employ comments to explain complex logic, delineate code sections, or clarify non-obvious design choices.
16. **Code Sections:** Use comments (e.g., `--- INIT ---`, `--- UPDATE ---`, `--- DRAW ---`, `--- HELPERS ---`) to clearly delineate logical sections of the codebase.