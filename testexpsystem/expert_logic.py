# expert_logic.py

def get_next_step(facts):
    
    if not facts or "start" in facts:
        return {"type": "question", "code": "KB_START"}

    # -----------------------------
    # Branch A: WITHOUT fever (0-1)
    # -----------------------------
    if "type:0-1" in facts:
        # Psoriasis / Eczema Check
        if "type:0-1-1" in facts:
            if "type:0-1-1-1" in facts: return {"type": "diagnosis", "result": "Psoriasis"}
            if "type:0-1-1-2" in facts: return {"type": "diagnosis", "result": "Eczema"}
            return {"type": "question", "code": "A_PSORIASIS_CHECK"}
        
        # Acne
        if "type:0-1-2" in facts: return {"type": "diagnosis", "result": "Acne"}
        
        # Ichthyosis
        if "type:0-1-3" in facts: return {"type": "diagnosis", "result": "Ichthyosis"}
        
        return {"type": "question", "code": "BRANCH_A"}

    # -----------------------------
    # Branch B: WITH fever (0-2)
    # -----------------------------
    if "type:0-2" in facts:
        # Meningitis
        if "type:0-2-1" in facts:
            if "type:0-2-1-1" in facts: return {"type": "diagnosis", "result": "Meningitis"}
            
            if "type:0-2-2" in facts: pass 
            else: return {"type": "question", "code": "MENINGITIS_CHECK"}
        
        # Measles / Scarlet Fever
        if "type:0-2-2" in facts:
            if "type:0-2-2-1" in facts: return {"type": "diagnosis", "result": "Measles"}
            if "type:0-2-2-2" in facts: return {"type": "diagnosis", "result": "Scarlet Fever"}
            return {"type": "question", "code": "MEASLES_SCARLET_CHECK"}

        return {"type": "question", "code": "BRANCH_B"}

    # -----------------------------
    # Branch C: Infections (0-3)
    # -----------------------------
    if "type:0-3" in facts:
        if "type:0-3-1" in facts: return {"type": "diagnosis", "result": "Insect Bite"}
        if "type:0-3-2" in facts: return {"type": "diagnosis", "result": "Warts"}
        return {"type": "question", "code": "BRANCH_C"}

    return {"type": "error", "message": "Step not defined"}