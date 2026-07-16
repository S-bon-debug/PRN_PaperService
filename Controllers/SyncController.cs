using Microsoft.AspNetCore.Mvc;
using PaperService.Services;
using Microsoft.Extensions.DependencyInjection;
using System.Threading.Tasks;
using System.Threading;

namespace PaperService.Controllers
{
    [ApiController]
    [Route("api/papers/[controller]")]
    public class SyncController : ControllerBase
    {
        private readonly Microsoft.Extensions.DependencyInjection.IServiceScopeFactory _scopeFactory;

        public SyncController(Microsoft.Extensions.DependencyInjection.IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
        }

        [HttpPost("trigger")]
        public async Task<IActionResult> TriggerSync(CancellationToken cancellationToken)
        {
            // Run async job in background, do not await it so API returns immediately
            _ = Task.Run(async () => { using var scope = _scopeFactory.CreateScope(); var syncJobService = scope.ServiceProvider.GetRequiredService<ISyncJobService>(); await syncJobService.DoSyncWorkAsync(CancellationToken.None); });
            return Accepted(new { message = "Sync job has been triggered and is running in the background." });
        }

        [HttpDelete("wipe")]
        public async Task<IActionResult> WipeMockData(CancellationToken cancellationToken)
        {
            using var scope = _scopeFactory.CreateScope(); var syncJobService = scope.ServiceProvider.GetRequiredService<ISyncJobService>(); await syncJobService.WipeMockDataAsync(cancellationToken);
            return Ok(new { message = "All mock data wiped successfully. Sync cursors have been reset." });
        }
    }
}
