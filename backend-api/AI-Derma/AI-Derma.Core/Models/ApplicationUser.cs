using Microsoft.AspNetCore.Identity;
using System;
using System.Collections.Generic;
using System.Text;

namespace AI_Derma.Core.Models
{
    public  class ApplicationUser : IdentityUser
    {
        public string Gender { get; set; }

        public int Age { get; set; } 

        public ICollection<DiagnosticResult> DiagnosticResults { get; set; }
        public ICollection<Feedback> Feedbacks { get; set; }
    }
}
