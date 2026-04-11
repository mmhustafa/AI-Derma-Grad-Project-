using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace AI_Derma.Core.DTOs
{
    public class RegisterDTO
    {
        [Required]
        public string UserName { get; set; }
        [Required]
        public string Email { get; set; }
        public string Gender { get; set; }
        public int Age { get; set; }
        [Required]
        public string Password { get; set; }
    }
}
