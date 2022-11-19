using Api.Models.Attach;

namespace Api.Models.Post
{
    public class CreatePostModel
    {
        public string Title { get; set; } = null!;
        public string? Tags { get; set; }
        public ICollection<MetadataModel> Metadata { get; set; } = null!;
    }
}
