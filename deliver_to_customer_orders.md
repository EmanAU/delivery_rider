
namespace TrackingApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    //[Authorize]
    public class DeliveryController : ControllerBase
    {

        private readonly IDeliveryService _deliveryService;

        public DeliveryController(IDeliveryService deliveryService)
        {
            _deliveryService = deliveryService;
        }




        [HttpPost("change-shipment-status")]
        public async Task<IActionResult> DeliverReturnOrderAsync([FromBody] EventLogRequestModel eventLogRequest)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                bool result = await _deliveryService.ChangeShipmentStatusAsync(eventLogRequest);

                if (result)
                    return Ok(new { message = "Status updated successfully." });

                return BadRequest(new { error = "Unable to update shipment status." });
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error occurred while delivering order." + ex.Message);

                return StatusCode(
                    StatusCodes.Status500InternalServerError,
                    new { error = "An internal server error occurred." }
                );
            }
        }

    }
}