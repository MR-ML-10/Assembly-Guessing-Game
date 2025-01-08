# **Guessing Game in Assembly**

An interactive number guessing game implemented in **MIPS Assembly**. The program challenges users to guess a randomly generated number based on a selected difficulty level. Features include real-time feedback, sound effects, and custom random number generation using an LCG (Linear Congruential Generator).

---

## **Features**

### **Core Functionalities**
1. **Random Number Generation**  
   - Generates pseudo-random numbers using a Linear Congruential Generator (LCG).
   - Supports difficulty-based ranges:  
     - Easy: 0–50  
     - Medium: 0–100  
     - Hard: 0–200  

2. **Difficulty Levels**  
   - Choose from three levels of difficulty for an adjustable challenge.

3. **User Feedback**  
   - Provides feedback for each guess:  
     - "Too High"  
     - "Too Low"  
     - "Correct"  

4. **Sound Effects**  
   - Plays MIDI sound effects:  
     - **Happy chords** for correct guesses.  
     - **Sad chords** for incorrect guesses.

5. **Input Validation**  
   - Ensures valid input:  
     - 9-digit number for seeding the random number generator.  
     - Valid guesses within the selected range.

---

## **Technologies Used**
- **Assembly (MIPS)**: Core programming language for game implementation.
- **MIDI System Calls**: For sound effect generation.
- **Python**: Includes a helper script to count lines of code in source files.

---

## **File Structure**
- **`asm6.s`**: Main program implementing the guessing game.  
- **`asm_line_count.py`**: Python script to count lines of non-commented code in source files.

---

## **How to Use**

### **Assembly Program**
1. **Setup**:  
   - Install a MIPS simulator (e.g., **SPIM** or **MARS**).  

2. **Run the Program**:  
   - Open the terminal and navigate to the directory containing `asm6.s`.
   - Run the following command:
     ```bash
     mars <guessing_game.asm>
     ```
   - Follow the prompts in the terminal to play the game.