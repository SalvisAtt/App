import tkinter as tk
import speech_recognition as sr
import pyttsx3
import pywhatkit
import datetime
import wikipedia

# Initialize recognizer and text-to-speech engine
listener = sr.Recognizer()
machine = pyttsx3.init()

# Function to speak out the text
def talk(text):
    machine.say(text)
    machine.runAndWait()

# Function to capture user instruction via microphone
def input_instruction():
    instruction = ""
    try:
        with sr.Microphone() as origin:
            print("Listening...")
            speech = listener.listen(origin)
            instruction = listener.recognize_google(speech)
            instruction = instruction.lower()
            if "tom" in instruction:
                instruction = instruction.replace('tom', '').strip()
                print("Command received:", instruction)
    except sr.UnknownValueError:
        talk("Sorry, I did not catch that. Could you please repeat?")
    except sr.RequestError:
        talk("Sorry, I'm having trouble connecting to the speech recognition service.")
    return instruction.strip()

# Command functions
def play_on_youtube(query):
    talk(f"Searching YouTube for {query}")
    try:
        pywhatkit.playonyt(query)
    except Exception as e:
        print("Error searching YouTube:", e)
        talk("I'm having trouble finding that video on YouTube.")

def tell_time():
    current_time = datetime.datetime.now().strftime('%I:%M %p')
    talk(f"The current time is {current_time}")
    return f"The current time is {current_time}"

def tell_date():
    current_date = datetime.datetime.now().strftime('%d/%m/%Y')
    talk(f"Today's date is {current_date}")
    return f"Today's date is {current_date}"

def provide_greeting():
    talk("Thanks! I'm fine. How about you?")
    return "Thanks! I'm fine. How about you?"

def tell_name():
    talk("I am Tom. What can I do for you?")
    return "I am Tom. What can I do for you?"

def search_wikipedia(query):
    talk(f"Searching for information on {query}")
    try:
        info = wikipedia.summary(query, sentences=1)
        print(info)
        talk(info)
        return info
    except wikipedia.exceptions.PageError:
        print("Exact match not found. Searching for closest match...")
        search_results = wikipedia.search(query)
        if search_results:
            closest_match = search_results[0]
            try:
                info = wikipedia.summary(closest_match, sentences=1)
                talk(f"I couldn't find an exact match, but here's information on {closest_match}:")
                print(info)
                talk(info)
                return info
            except Exception as e:
                talk("Sorry, I couldn't find any information.")
                print(e)
        else:
            talk("Sorry, I couldn't find any information.")
    return "No information found."

def calculate(expression):
    try:
        result = eval(expression)
        talk(f"The answer is {result}")
        print(f"Calculation result: {result}")
        return f"The answer is {result}"
    except Exception as e:
        talk("Sorry, I couldn't calculate that.")
        print("Calculation error:", e)
    return "Calculation error."

# Central function to handle commands
def play_jarvis(text_input=None):
    instruction = text_input if text_input else input_instruction()
    print("Processed instruction:", instruction)
    
    if any(keyword in instruction for keyword in ["play", "search for", "find"]):
        song = instruction.replace("play", "").replace("search for", "").replace("find", "").strip()
        play_on_youtube(song)
        return f"Playing {song} on YouTube."
    elif "time" in instruction:
        return tell_time()
    elif "date" in instruction:
        return tell_date()
    elif "how are you" in instruction:
        return provide_greeting()
    elif "what is your name" in instruction:
        return tell_name()
    elif "who is" in instruction:
        human = instruction.replace("who is", "").strip()
        return search_wikipedia(human)
    elif any(keyword in instruction for keyword in ["calculate", "what is", "solve"]):
        expression = instruction.replace("calculate", "").replace("what is", "").replace("solve", "").strip()
        return calculate(expression)
    elif "goodbye" in instruction or "exit" in instruction:
        talk("Goodbye! Have a great day!")
        return "Goodbye! Have a great day!"
    else:
        talk("Please repeat.")
        return "Please repeat."

# GUI setup
root = tk.Tk()
root.title("Voice Assistant Chat")
root.geometry("400x500")

# Conversation display area
conversation_area = tk.Text(root, height=20, width=50)
conversation_area.pack(pady=10)

# Entry field for text input
entry_field = tk.Entry(root, width=40)
entry_field.pack(pady=5)

# Function to handle text input
def handle_text_command():
    user_command = entry_field.get()
    conversation_area.insert(tk.END, f"You: {user_command}\n")
    entry_field.delete(0, tk.END)
    
    response = play_jarvis(user_command)
    conversation_area.insert(tk.END, f"Assistant: {response}\n")

# Function to handle voice command
def handle_voice_command():
    conversation_area.insert(tk.END, "Listening...\n")
    root.update()
    response = play_jarvis()
    conversation_area.insert(tk.END, f"Assistant: {response}\n")

# Buttons for text and voice commands
text_button = tk.Button(root, text="Send Text Command", command=handle_text_command)
text_button.pack(pady=5)
voice_button = tk.Button(root, text="Speak", command=handle_voice_command)
voice_button.pack(pady=5)

# Run the GUI
root.mainloop()
