using Common;

namespace Api.Models.User
{
    public class UserModel
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public string Email { get; set; } = null!;
        public DateTimeOffset BirthDay { get; set; }
        public DateTimeOffset LastActive { get; set; }
        public string? AvatarLink { get; set; }
        public string? Status { get; set; }
        public int TotalPosts { get; set; }
        public int TotalComments { get; set; }
        
    }
}
