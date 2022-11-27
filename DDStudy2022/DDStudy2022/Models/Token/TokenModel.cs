namespace Api.Models.Token
{
    public class TokenModel
    {
        public string AccessToken { get; set; }
        public string RefreshToken { get; set; }
        public Guid UserId { get; set; }
        public TokenModel(string accessToken, string refreshToken, Guid userId)
        {
            AccessToken = accessToken;
            RefreshToken = refreshToken;
            UserId = userId;
        }
    }
}
