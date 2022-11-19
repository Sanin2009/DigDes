using Api.Models.Attach;
using Api.Models.Comment;
using Api.Models.Post;
using Api.Models.User;
using AutoMapper;
using Common;
using DAL.Entities;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Api
{
    public class MapperProfile: Profile
    {
        public MapperProfile() {
            CreateMap<CreateUserModel, DAL.Entities.User>()
                .ForMember(d=>d.Id, m=>m.MapFrom(s=>Guid.NewGuid()))
                .ForMember(d=>d.PasswordHash, m=>m.MapFrom(s=>HashHelper.GetHash(s.Password)))
                .ForMember(d=>d.BirthDay, m=>m.MapFrom(s=>s.BirthDay.UtcDateTime))
                ;
            CreateMap<DAL.Entities.User, UserModel>()
                .ForMember(d=>d.TotalPosts, m=>m.MapFrom(s=>s.UserPosts!.Count))
                .ForMember(d=>d.AvatarLink, m => m.MapFrom(s => LinkHelper.Avatar(s.Id)))
                .ForMember(d => d.TotalComments, m => m.MapFrom(s => s.Comments!.Count));

            CreateMap<DAL.Entities.Avatar, AttachModel>();

            CreateMap<DAL.Entities.Attach, AttachModel>();

            CreateMap<DAL.Entities.UserPost, ShowPostModel>();

            CreateMap<DAL.Entities.Comment, ShowCommentModel>()
                .ForMember(d=>d.AvatarLink, m=>m.MapFrom(s=>LinkHelper.Avatar(s.UserId)));

        }


    }
}
