﻿using DAL.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class DataContext : DbContext
    {
        public DataContext(DbContextOptions<DataContext> options) : base(options)
        {

        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder
                .Entity<User>()
                .HasIndex(f => f.Email)
                .IsUnique();
            modelBuilder
               .Entity<User>()
               .HasIndex(f => f.Name)
               .IsUnique();

            modelBuilder.Entity<Avatar>().ToTable(nameof(Avatars));

            modelBuilder.Entity<PostLike>()
                .HasKey(p => new { p.UserId, p.UserPostId });
            modelBuilder.Entity<UserPost>()
                .HasIndex(f => f.Created);

        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
            => optionsBuilder.UseNpgsql(b => b.MigrationsAssembly("Api"));

        public DbSet<User> Users => Set<User>();
        public DbSet<UserSession> UserSessions => Set<UserSession>();
        public DbSet<Attach> Attaches => Set<Attach>();
        public DbSet<Avatar> Avatars => Set<Avatar>();
        public DbSet<UserPost> UserPosts => Set<UserPost>();
        public DbSet<Comment> Comments => Set<Comment>();
        public DbSet<PostImage> PostImages => Set<PostImage>();
        public DbSet<PostLike> PostLikes => Set<PostLike>();
        public DbSet<Subscriber> Subscribers => Set<Subscriber>();
    }
}
