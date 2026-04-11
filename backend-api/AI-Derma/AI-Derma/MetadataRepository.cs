using System.Text.Json;
using AI_Derma.Core.Interfaces;
using AI_Derma.Core.JsonModels;

namespace AI_Derma
{
    public class MetadataRepository : IMetadata
    {

      
        private readonly IWebHostEnvironment _env;

        public MetadataRepository(IWebHostEnvironment env)
        {
            _env = env;
        }
        public QuestionsMetadata questionsMetadata()
        {
            var filePath = Path.Combine(_env.ContentRootPath, "KB_Metadata.json");
            var jsonString = File.ReadAllText(filePath);
            return JsonSerializer.Deserialize<QuestionsMetadata>(jsonString, new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            });

        }
    }
}
