﻿namespace Api.Models.User
{
    public class UserModel
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public DateTimeOffset BirthDay { get; set; }

        public UserModel(Guid id, string name, string email, DateTimeOffset birthDay)
        {
            Id = id;
            Name = name;
            Email = email;
            BirthDay = birthDay;
        }
    }
}
