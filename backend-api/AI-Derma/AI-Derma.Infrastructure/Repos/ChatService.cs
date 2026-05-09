using AI_Derma.Core.DTOs;
using AI_Derma.Core.Interfaces;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

namespace AI_Derma.Infrastructure.Repos
{
    public class ChatService: IChatService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _config;
        private readonly IMemoryCache _cache;

        public ChatService(HttpClient httpClient, IConfiguration config, IMemoryCache cache)
        {
            _httpClient = httpClient;
            _config = config;
            _cache = cache;

            var apiKey = _config["Groq:ApiKey"];
            _httpClient.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", apiKey);
        }
        public async Task<string> GetResponseAsync(ChatRequestDto request)
        {
            if (IsMedicationQuestion(request.Message))
            {
                return "I can't provide medical prescriptions. Please consult a healthcare professional.";
            }

            var history = GetConversationHistory(request.SessionId);

            var prompt = BuildPrompt(request, history);

            var body = new
            {
                model = "llama-3.1-8b-instant",
                messages = new[]
                {
                new
                {
                    role = "system",
                    content = "You are a dermatology assistant."
                },
                new
                {
                    role = "user",
                    content = prompt
                }
            },
                temperature = 0.7
            };

            var response = await _httpClient.PostAsync(
                "https://api.groq.com/openai/v1/chat/completions",
                new StringContent(JsonSerializer.Serialize(body), Encoding.UTF8, "application/json")
            );

            if (!response.IsSuccessStatusCode)
                return "Something went wrong.";

            var json = await response.Content.ReadAsStringAsync();

            using var doc = JsonDocument.Parse(json);

            var reply = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString();

            SaveConversation(request.SessionId, request.Message, reply);

            return reply ?? "No response.";
        }

        private string BuildPrompt(ChatRequestDto request, List<string> history)
        {
            var uncertainty = request.Confidence < 0.7
                ? "Important: The AI prediction confidence is low, so avoid presenting the condition as certain and encourage consulting a dermatologist."
                : "";

            var historyText = string.Join("\n", history);

            return $@"
            You are an AI dermatology assistant for the AI-Derma system.

            Detected Skin Condition: {request.Condition}
            Prediction Confidence: {request.Confidence}

            {uncertainty}

            Conversation History:
            {historyText}

            STRICT RULES:
            - ONLY answer questions related to:
              - skin diseases
              - dermatology
              - skincare
              - symptoms
              - skin condition prevention
              - general skin health
            - If the user asks about ANY non-skin-related topic, respond with:
              'I can only assist with skin and dermatology-related questions.'
            - Do NOT prescribe medications or treatment plans.
            - Do NOT provide dangerous medical advice.
            - Keep explanations simple and clear.
            - Mention seeing a dermatologist if symptoms appear serious or persistent.
            - If confidence is low, mention uncertainty clearly.
            - Ask ONLY ONE short follow-up question when appropriate.
            - Keep responses concise and user-friendly.

            Current User Message:
            {request.Message}
            ";
        }

        private List<string> GetConversationHistory(string sessionId)
        {
            if (_cache.TryGetValue(sessionId, out List<string> history))
                return history;

            return new List<string>();
        }

        private void SaveConversation(string sessionId, string userMsg, string botReply)
        {
            var history = GetConversationHistory(sessionId);

            history.Add($"User: {userMsg}");
            history.Add($"Bot: {botReply}");

            if (history.Count > 6)
                history = history.Skip(history.Count - 6).ToList();

            _cache.Set(sessionId, history, TimeSpan.FromMinutes(30));
        }

        private bool IsMedicationQuestion(string message)
        {
            var keywords = new[] { "medicine", "drug", "antibiotic", "dose" };
            return keywords.Any(k => message.ToLower().Contains(k));
        }


    }
}
