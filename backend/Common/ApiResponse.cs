using System.Text.Json.Serialization;
using System.Diagnostics;

namespace backend.Common
{
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public T? Data { get; set; }
        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public string? TraceId { get; set; }

        public static ApiResponse<T> SuccessResult(T data, string message = "İşlem başarılı.")
        {
            return new ApiResponse<T> 
            { 
                Success = true, 
                Message = message, 
                Data = data 
            };
        }

        public static ApiResponse<T> ErrorResult(string message, string? traceId = null)
        {
            return new ApiResponse<T> 
            { 
                Success = false, 
                Message = message, 
                Data = default,
                TraceId = traceId ?? Activity.Current?.TraceId.ToString()
            };
        }
    }
}
