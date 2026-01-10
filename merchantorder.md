
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


//[Authorize]
    public class RiderOrdersController : ControllerBase
    {

        private readonly IRiderOrdersService _riderOrdersService;

        public RiderOrdersController(IRiderOrdersService riderOrdersService)
        {
            _riderOrdersService = riderOrdersService;
        }

        [HttpGet("merchant-branch-orders")]
        public async Task<ActionResult> GetMerchantToBranchOrdersAsync(string RiderId)
        {
            if (string.IsNullOrWhiteSpace(RiderId))
                return BadRequest(new { error = "RiderId is required." });

            try
            {
                var orders = await _riderOrdersService.GetMerchantToBranchOrdersAsync(RiderId);

                if (orders == null || orders.Count == 0)
                    return NotFound(new { message = "No orders found for this rider." });

                return Ok(orders);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError,
                    new { error = "Failed to fetch orders.", details = ex.Message });
            }
        }


        [HttpGet("branch-to-customer")]
        public async Task<IActionResult> GetBranchToCustomerOrdersAsync([FromQuery] string riderId)
        {

            if (string.IsNullOrWhiteSpace(riderId))
                return BadRequest("RiderId is required.");

            try
            {
                var orders = await _riderOrdersService.GetBranchToCustomerOrdersAsync(riderId);

                if (orders == null || orders.Count == 0)
                    return NotFound("No branch-to-customer orders found for this rider.");

                return Ok(orders);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error fetching orders: {ex.Message}");
            }

        }

        [HttpGet("branch-to-merchant-return")]
        public async Task<IActionResult> GetBranchToMerchantReturnOrdersAsync([FromQuery] string riderId)
        {
            if (string.IsNullOrWhiteSpace(riderId))
                return BadRequest("RiderId is required.");
            try
            {
                var orders = await _riderOrdersService.GetBranchToMerchantReturnOrdersAsync(riderId);
                if (orders == null || orders.Count == 0)
                    return NotFound("No branch to Merchant orders found for this rider.");

                return Ok(orders);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Error fetching orders: {ex.Message}");
            }

        }
        

        [HttpGet("verify-otp")]
        public async Task<IActionResult> VerifyOtpAsync([FromQuery] string merchantOrderId, [FromQuery] int otp)
        {
            if (string.IsNullOrWhiteSpace(merchantOrderId))
                return BadRequest(new { error = "MerchantOrderId is required." });

            try
            {
                var isVerified = await _riderOrdersService.VerifyOtp(merchantOrderId, otp);
                return Ok(new { isVerified });
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError,
                    new { error = "Failed to verify OTP.", details = ex.Message });
            }
        }

    }
}