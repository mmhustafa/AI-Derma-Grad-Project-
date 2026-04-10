namespace AI_Derma.Core.Models
{
    public class Feedback
    {
        public int Id { get; set; }
        public string UserId { get; set; }
        public ApplicationUser User { get; set; }
        public int ResultId { get; set; }
        public DiagnosticResult Result { get; set; }
        public int Rating { get; set; } 
        public string Comments { get; set; }
     
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}