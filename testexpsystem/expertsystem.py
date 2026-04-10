# Pure Python forward-chaining expert system converted from CLIPS
# Extended to implement the full flow (Branch A, B, and C) described by the user.

import sys

# -----------------------------
# Fact Base and Engine Utilities
# -----------------------------

facts = []
halted = False

def assert_fact(fact):
    facts.append(fact)

def retract_fact(fact):
    if fact in facts:
        facts.remove(fact)

def read():
    try:
        return input().strip()
    except EOFError:
        return ""

def halt():
    global halted
    halted = True

# -----------------------------
# Initial Facts (deffacts init)
# -----------------------------

assert_fact(("start",))

# -----------------------------
# Rule Definitions (defrule)
# -----------------------------

# defrule mainmenu
def rule_mainmenu():
    if ("start",) in facts:
        retract_fact(("start",))
        print("\n" * 3)
        print(
            "An expert system for Diagnosis of some skin diseases\n\n"
            "Main Menu\n"
            "=========\n\n"
            "1 - Skin rashes WITHOUT fever --> Go to Branch A\n"
            "2 - Skin rashes WITH fever    --> Go to Branch B\n"
            "3 - Skin infections            --> Go to Branch C\n"
            "0 - Quit                      --> END\n\n"
            "Type number of your choice then hit return key\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-1"))
        elif response == "2":
            assert_fact(("type", "0-2"))
        elif response == "3":
            assert_fact(("type", "0-3"))
        elif response == "0":
            assert_fact(("type", "quit"))
        else:
            # invalid input: return to main menu
            assert_fact(("start",))
        print()

# defrule user-quits
def rule_user_quits():
    if ("type", "quit") in facts:
        print("You have QUIT the program.")
        halt()

# Branch A: Skin Rashes WITHOUT Fever (Q2)
def rule_without():
    if ("type", "0-1") in facts:
        retract_fact(("type", "0-1"))
        print("\n" * 2)
        print(
            "Diagnosis of some skin diseases\n\n"
            "Skin rashes WITHOUT fever (Branch A)\n"
            "==================================\n\n"
            "1 - Red patches, painful joints, pitted nails, dandruff  -> Psoriasis / Eczema Check\n"
            "2 - Blackheads/whiteheads, oily skin, pimples/cysts      -> Acne Check\n"
            "3 - Characteristic fish-scale rash                       -> Ichthyosis Check\n"
            "0 - Go to Main Menu\n\n"
            "Type number of your choice then hit return\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-1-1"))
        elif response == "2":
            assert_fact(("type", "0-1-2"))
        elif response == "3":
            assert_fact(("type", "0-1-3"))
        elif response == "0":
            assert_fact(("start",))
        else:
            # invalid -> return to this menu
            assert_fact(("type", "0-1"))

# Psoriasis / Eczema Check
def rule_red_patches():
    if ("type", "0-1-1") in facts:
        retract_fact(("type", "0-1-1"))
        print("\n" * 2)
        print(
            "Psoriasis / Eczema Check\n"
            "------------------------\n"
            "Do you have red patches of skin, painful joints, pitted nails, or dandruff?\n\n"
            "1 - Yes (then: Do the patches develop white-silvery scales and stiffness?)\n"
            "2 - No  (then: Do small blisters develop that may ooze, with itching and thickened skin?)\n"
            "0 - Go to Previous Menu\n\n"
            "Type number of your choice then hit return\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-1-1-1"))
        elif response == "2":
            assert_fact(("type", "0-1-1-2"))
        elif response == "0":
            assert_fact(("type", "previous", "0-1"))
        else:
            assert_fact(("type", "0-1-1"))

def rule_previous0_1():
    if ("type", "previous", "0-1") in facts:
        retract_fact(("type", "previous", "0-1"))
        assert_fact(("type", "0-1"))

def rule_psoriasis():
    if ("type", "0-1-1-1") in facts:
        retract_fact(("type", "0-1-1-1"))
        print("\n" * 2)
        print(
            "Diagnosis: Psoriasis\n"
            "Based on: red patches of skin with white-silvery scales and stiffness.\n\n"
            "Enter any key then press Enter to continue ...\n"
        )
        read()
        assert_fact(("start",))

def rule_eczema():
    if ("type", "0-1-1-2") in facts:
        retract_fact(("type", "0-1-1-2"))
        print("\n" * 2)
        print(
            "Diagnosis: Eczema (Atopic Dermatitis)\n"
            "Based on: small blisters that may ooze, itching and thickened skin.\n\n"
            "Enter any key then press Enter to continue ...\n"
        )
        read()
        assert_fact(("start",))

# Acne Check
def rule_blackheads():
    if ("type", "0-1-2") in facts:
        retract_fact(("type", "0-1-2"))
        print("\n" * 2)
        print(
            "Acne Check\n"
            "----------\n"
            "Do you have blackheads/whiteheads, oily skin, pimples, or cysts on face/chest/back?\n\n"
            "1 - Yes\n"
            "0 - No (Return to Previous Menu)\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            print("\nDiagnosis: Acne\n\nEnter any key then press Enter to continue ...\n")
            read()
            assert_fact(("start",))
        else:
            assert_fact(("type", "previous", "0-1"))

# Ichthyosis Check
def rule_fish_scales():
    if ("type", "0-1-3") in facts:
        retract_fact(("type", "0-1-3"))
        print("\n" * 2)
        print(
            "Ichthyosis Check\n"
            "----------------\n"
            "Do you have a fish-scale-like rash (especially elbows, knees, hands) since early childhood?\n\n"
            "1 - Yes\n"
            "0 - No (Return to Previous Menu)\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            print("\nDiagnosis: Ichthyosis\n\nEnter any key then press Enter to continue ...\n")
            read()
            assert_fact(("start",))
        else:
            assert_fact(("type", "previous", "0-1"))

# Branch B: Skin Rashes WITH Fever (Q3)
def rule_with():
    if ("type", "0-2") in facts:
        retract_fact(("type", "0-2"))
        print("\n" * 2)
        print(
            "Skin rashes WITH fever (Branch B)\n"
            "================================\n\n"
            "1 - Severe headache, stiff neck, fever, confusion, rash -> Meningitis Check\n"
            "2 - Cough, fever, runny nose, spreading red itchy rash, grayish bumps in mouth -> Measles / Scarlet Fever Check\n"
            "0 - Go to Main Menu\n\n"
            "Type number of your choice then hit return\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-2-1"))
        elif response == "2":
            assert_fact(("type", "0-2-2"))
        elif response == "0":
            assert_fact(("start",))
        else:
            assert_fact(("type", "0-2"))

# Meningitis Check
def rule_meningitis_check():
    if ("type", "0-2-1") in facts:
        retract_fact(("type", "0-2-1"))
        print("\n" * 2)
        print(
            "Meningitis Check\n"
            "----------------\n"
            "Do you have severe headache, stiff neck, fever, confusion, and rash?\n\n"
            "1 - Yes\n"
            "0 - No (Proceed to Measles/Scarlet Fever Check)\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-2-1-1"))
        else:
            # proceed to measles/scarlet fever
            assert_fact(("type", "0-2-2"))

def rule_meningitis_diagnosis():
    if ("type", "0-2-1-1") in facts:
        retract_fact(("type", "0-2-1-1"))
        print("\n" * 2)
        print(
            "Diagnosis: Meningitis (Medical emergency)\n"
            "If suspected, seek immediate medical care (emergency department).\n\n"
            "Enter any key then press Enter to continue ...\n"
        )
        read()
        assert_fact(("start",))

# Measles / Scarlet Fever Check
def rule_measles_scarlet_check():
    if ("type", "0-2-2") in facts:
        retract_fact(("type", "0-2-2"))
        print("\n" * 2)
        print(
            "Measles / Scarlet Fever Check\n"
            "-----------------------------\n"
            "Do you have cough, fever, runny nose, and a spreading red itchy rash with grayish bumps in the mouth (Koplik spots)?\n\n"
            "1 - Yes (Measles likely)\n"
            "2 - No  (Then check for Scarlet Fever)\n"
            "0 - Go to Previous Menu\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-2-2-1"))
        elif response == "2":
            # proceed to scarlet fever question
            assert_fact(("type", "0-2-2-2"))
        elif response == "0":
            assert_fact(("type", "previous", "0-2"))
        else:
            assert_fact(("type", "0-2-2"))

def rule_measles_diagnosis():
    if ("type", "0-2-2-1") in facts:
        retract_fact(("type", "0-2-2-1"))
        print("\n" * 2)
        print(
            "Diagnosis: Measles (Rubeola)\n"
            "Supportive care and medical advice recommended; isolated if suspected.\n\n"
            "Enter any key then press Enter to continue ...\n"
        )
        read()
        assert_fact(("start",))

def rule_scarlet_check_and_diagnosis():
    if ("type", "0-2-2-2") in facts:
        retract_fact(("type", "0-2-2-2"))
        print("\n" * 2)
        print(
            "Scarlet Fever Check\n"
            "-------------------\n"
            "Do you have sore throat, fever, strawberry tongue, and sandpaper-like rash?\n\n"
            "1 - Yes (Scarlet Fever likely)\n"
            "0 - No  (Return to Q3)\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            print("\nDiagnosis: Scarlet Fever\n\nEnter any key then press Enter to continue ...\n")
            read()
            assert_fact(("start",))
        else:
            assert_fact(("type", "previous", "0-2"))

def rule_previous0_2():
    if ("type", "previous", "0-2") in facts:
        retract_fact(("type", "previous", "0-2"))
        assert_fact(("type", "0-2"))

# Branch C: Skin Infections (Q4)
def rule_infections():
    if ("type", "0-3") in facts:
        retract_fact(("type", "0-3"))
        print("\n" * 2)
        print(
            "Skin Infections (Branch C)\n"
            "==========================\n\n"
            "1 - Insect bite/sting: red, painful lump, systemic signs possible -> Insect Bites & Stings Check\n"
            "2 - Firm round lumps with rough surface and tiny black spots -> Warts Check\n"
            "0 - Go to Main Menu\n\n"
            "Type number of your choice then hit return\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            assert_fact(("type", "0-3-1"))
        elif response == "2":
            assert_fact(("type", "0-3-2"))
        elif response == "0":
            assert_fact(("start",))
        else:
            assert_fact(("type", "0-3"))

def rule_insect_bites_check():
    if ("type", "0-3-1") in facts:
        retract_fact(("type", "0-3-1"))
        print("\n" * 2)
        print(
            "Insect Bites & Stings Check\n"
            "---------------------------\n"
            "Did symptoms start after an insect bite/sting with redness, swelling, pain, or numbness?\n\n"
            "1 - Yes\n"
            "0 - No (Proceed to next infection check - Warts)\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            print("\nDiagnosis: Insect Bite / Sting Reaction\n\nEnter any key then press Enter to continue ...\n")
            read()
            assert_fact(("start",))
        else:
            # proceed to warts check
            assert_fact(("type", "0-3-2"))

def rule_warts_check():
    if ("type", "0-3-2") in facts:
        retract_fact(("type", "0-3-2"))
        print("\n" * 2)
        print(
            "Warts Check\n"
            "-----------\n"
            "Do you have firm, round lumps with rough surface and tiny black dots (usually on hands)?\n\n"
            "1 - Yes\n"
            "0 - No (Return to Q4)\n\n"
            "Choice: ",
            end=""
        )
        response = read()
        if response == "1":
            print("\nDiagnosis: Warts (HPV)\n\nEnter any key then press Enter to continue ...\n")
            read()
            assert_fact(("start",))
        else:
            assert_fact(("type", "previous", "0-3"))

def rule_previous0_3():
    if ("type", "previous", "0-3") in facts:
        retract_fact(("type", "previous", "0-3"))
        assert_fact(("type", "0-3"))

# -----------------------------
# Inference Engine Loop
# -----------------------------

rules = [
    rule_mainmenu,
    rule_user_quits,

    # Branch A rules
    rule_without,
    rule_red_patches,
    rule_previous0_1,
    rule_psoriasis,
    rule_eczema,
    rule_blackheads,
    rule_fish_scales,

    # Branch B rules
    rule_with,
    rule_meningitis_check,
    rule_meningitis_diagnosis,
    rule_measles_scarlet_check,
    rule_measles_diagnosis,
    rule_scarlet_check_and_diagnosis,
    rule_previous0_2,

    # Branch C rules
    rule_infections,
    rule_insect_bites_check,
    rule_warts_check,
    rule_previous0_3,
]

while not halted:
    fired = False
    for rule in rules:
        before = list(facts)
        rule()
        if facts != before:
            fired = True
            break
    if not fired:
        break
