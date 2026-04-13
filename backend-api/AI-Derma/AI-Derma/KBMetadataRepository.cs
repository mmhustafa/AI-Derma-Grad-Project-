using AI_Derma.Core.Interfaces;
using AI_Derma.Core.JsonModels;
using Microsoft.Extensions.Caching.Memory;
using System.Text.Json;

namespace AI_Derma
{
    public class KBMetadataRepository : IKBMetadata
    {


        private readonly IWebHostEnvironment _env;
        private readonly IMemoryCache _cache;

        public KBMetadataRepository(IWebHostEnvironment env, IMemoryCache cache)
        {
            _env = env;
            _cache = cache;
        }

        public QuestionsMetadata questionsMetadata()
        {
            const string cacheKey = "KB_METADATA";

            if (!_cache.TryGetValue(cacheKey, out QuestionsMetadata metadata))
            {
                var filePath = Path.Combine(_env.ContentRootPath, "KB_Metadata.json");
                var jsonString = File.ReadAllText(filePath);

                metadata = JsonSerializer.Deserialize<QuestionsMetadata>(jsonString, new JsonSerializerOptions
                {
                    PropertyNameCaseInsensitive = true
                });

                var cacheOptions = new MemoryCacheEntryOptions()
                    .SetSlidingExpiration(TimeSpan.FromMinutes(30)) 
                    .SetAbsoluteExpiration(TimeSpan.FromHours(2)); 

                _cache.Set(cacheKey, metadata, cacheOptions);
            }

            return metadata;
        }
    }
}
