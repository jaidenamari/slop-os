---
Description: Creates a concise engineering implementation plan based on user requirments and saves it to specs directory
argument-hint: [user prompt]
Model: opus
---

Title: Concise Implementation Plan Generator

# Quick Plan
Creates a concise engineering implementation plan based on user requirements and saves it to specs directory

# Variables

USER_PROMPT: ${ARGUMENTS}
PLAN_OUTPUT_DIRECTORY: `specs/`

# Instructions

- Carefully analyze user requirements in USER_PROMPT variable.
- Think deeply about the best approach to implement the requested functionality or solve the problem 
- Create a concise implementation plan that includes
    - Clear problem statement and objectives
    - Technical approach and architecture decisions
    - Step-by-step implemention guide
    - Challenges and solutions
    - Testing strategy
    - Success Criteria
- Generate a descriptive, kebab-case filename based on the main topic of the plan
- Save the complete implementation plan to `PLAN_OUTPUT_DIRECTORY/<description-name>.md`
- Ensure the plan is detailed enought hat another developer could follow it to implement the solution
-Include code examples or pseudo-code where approriate to clarify complex concepts
- Consider ege cases, error handling, and scalability concerns
-Structure the document with clear seciton and proper markdown formatting.

# Workflow
   1. Analyze Requirements - THINK HARD and parse the USER_PROMPT to understand the core problem and desired outcome.
   2. Design Solution - Develop technical approach including architecture decisions and implementation strategy.
   3. Document Plan - Structure a comprehensive markdown document with problem statement, implementation steps, and testing approach.
   4. Generate Filename - kebab-case based on main topic
   5. Save & Report - Write to PLAN_OUTPUT_DIRECTORY/<filename>.md and provide a summary of key components

# Report
   ==Implementation Plan Created==
   File: PLAN_OUTPUT_DIRECTORY/<filename>.md
   Topic: <brief description>
   Key Components:
   - main component 1
   - main component 2
   - main component 3
   - ...