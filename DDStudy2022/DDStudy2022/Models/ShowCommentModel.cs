﻿namespace Api.Models
{
    public class ShowCommentModel
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = null!;
        public string Message { get; set; } = null!;
        public DateTimeOffset Created { get; set; }
        public ShowCommentModel (Guid id, string name, string message, DateTimeOffset created)
        {
            Id = id;
            Name = name;
            Message = message;
            Created = created;
        }
    }
}