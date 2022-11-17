using Common;

namespace Api.Models.Comment
{
    public class ShowCommentModel
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public string Message { get; set; } = null!;
        public DateTimeOffset Created { get; set; }
        public string AvatarLink { get; set; } = null!;  
    }
}
