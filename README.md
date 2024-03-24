# IntegralBeeApp

Desktop application for Windows that runs an MIT-style knockout integration bee. Players solve integrals in one-on-one matches under timed conditions.

## Features
- Automatic timer with pause and early finish
- Supports up to four pairs playing at a time
- Randomised draw and automatically updates with each round
- Assigns integrals based on year group and whether students are studying A Level Further Mathematics
- Point allocation based on number of students per school
- Integrals rendered using LaTeX
- Generates LaTeX showing integrals and answers
- Generates LaTeX showing integrals and answers on separate pages
- Error detection and validation for settings and integrals

## Examples

![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/0f4667ed-932e-4f3e-8ec8-c3322781f4cd)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/1d6aa82b-afb4-4ceb-a92b-ce5358ec2cc9)

![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/8b62f142-e914-427e-88ad-de46e4adcf97)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/9199bf39-8636-46c5-9e80-8bf4e2e7ac62)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/af9f1a88-17b4-4579-a69a-9ed535ba5698)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/8564ee14-c86c-43a8-b44f-40d0d63f64d5)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/c0f99009-316e-4737-995e-4f6e2d0b5813)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/91356175-ef66-4be2-a47f-f38cc681dcca)
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/0f19bc41-d57b-46b6-8853-0056001f85a1)

## Installation

Download and extract the folder from the Releases section, then run the executable file.

## Usage

### Adding integrals

1. Go to [Integral Entry online app](https://alunity.github.io/integral-entry/) to generate and download the text file containing the integral data.
2. Navigate to the 'Add integrals' section.
3. Import the text file containing the integral data.
4. Resolve all of the issues shown and re-upload.
5. Once all of the errors have been resolved, click Save

### Generating the integral/answer LaTeX

1. Select 'Generate integral/answer LaTeX' to generate the raw LaTeX code.
2. Compile the LaTeX code separately, ensuring that all required packages are installed.

Note that equations that overflow may need to be manually split up in the LaTeX code.

When compiled, the LaTeX document will look like the following:
![image](https://github.com/Dinu-Filip/IntegralBeeApp/assets/65129331/5750d9e6-37ed-4d07-8eba-249b785918a8)

### Changing the settings

1. Navigate to 'Settings'.
2. Update settings as required. 'Times per round' allows you to set the number of seconds per integral and 'Num. integrals per round' allows you to set the number of integrals for each 'best-of' match. Note that exactly four values must be provided for each of these fields (for rounds before the quarterfinal, quarterfinal, semifinal, final).
4. Save changes and reload the application (optionally to update host school and competition title).

### Additional info
- Matches are best-of with an odd number of integrals.
- In a tiebreak, the first player to answer an integral correctly wins. The pairs in a tiebreak will be shown in blue.
- Players are given byes in the first round so that the second round always has a power of two as the number of participants.
- Any matches that were in progress when closing the application are restarted when loading from previous.
