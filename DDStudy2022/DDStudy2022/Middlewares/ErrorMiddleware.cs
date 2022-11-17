using Api.Consts;
using Api.Services;
using Common;
using Common.Extentions;
using DAL.Entities;

namespace Api.Middlewares
{
    public class ErrorMiddleware
    {
        private readonly RequestDelegate _next;

        public ErrorMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            try
            {
                await _next(context);
            }
            catch (NotFound ex)
            {
                context.Response.StatusCode = 404;
                await context.Response.WriteAsJsonAsync(ex.Message);
            }
            catch (BadRequest ex)
            {
                context.Response.StatusCode = 400;
                await context.Response.WriteAsJsonAsync(ex.Message);
            }
            catch (NoAccess ex)
            {
                context.Response.StatusCode = 403;
                await context.Response.WriteAsJsonAsync(ex.Message);
            }
        }
    }
    public static class ErrorMiddlewareExtensions
    {
        public static IApplicationBuilder UseGlobalErrorWrapper(
            this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<ErrorMiddleware>();
        }
    }
}
