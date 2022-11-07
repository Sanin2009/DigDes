namespace Api.Models
{
    public class CreatePostModel
    {
        public string Title { get; set; } = null!;
        public ICollection<MetadataModel> Metadata { get; set; } = null!;
    }
}
