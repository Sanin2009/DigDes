
namespace DAL.Entities
{
    public class Comment
    {
        public Guid Id { get; set; }
        public Guid UserId { get; set; }
        public string Message { get; set; } = null!;
        public string Name { get; set; } = null!;
        public Guid UserPostId { get; set; }
        public DateTimeOffset Created { get; set; }
        public virtual UserPost UserPost { get; set; } = null!;
        public virtual User User { get; set; } = null!;

    }
}
