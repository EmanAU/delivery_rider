SOAR API
1. Getting Started (Authentication)
Before a rider can do anything, they need to log in to identify which specific Branch they belong
to.
• Action: Rider enters credentials.
• API Endpoint: POST /rider-login
• Result: You will get a JWT Access Token. You must save this token and send it in the
header of all future requests.

Flow 1: The Pickup (Merchant -> Branch)
This is the "First Mile." The rider collects parcels from a shop (Merchant) and brings them to the
Rider's home Branch.
• Step A (See Tasks): The rider needs to see a list of orders waiting to be picked up from
Merchants.
o Use Endpoint: GET /merchant-branch-orders
• Step B (Action - Pickup): When the rider physically picks up the parcel from the
Merchant.
o Use Endpoint: POST /change-shipment-status
o Status to send: "Picked by Rider"
• Step C (Drop off): The rider drops it at the Branch.
o Note: The app does not need to do anything here. The Branch Manager will scan
the parcel on their portal to mark it as "Received."


-----------------------------------------------------------------------------------------
Flow 2: The Delivery (Branch -> Customer)
This is the "Last Mile." The parcel has arrived at the destination Branch, and the manager has
assigned it to a Rider to deliver to the Customer.
• Step A (See Tasks): The rider needs to see a list of orders assigned to them for final
delivery.
o Use Endpoint: GET /branch-to-customer
• Step B (Action - Start Journey): When the rider leaves the branch with the parcel.
o Use Endpoint: POST /change-shipment-status
o Status to send: "Rider is on the way"
• Step C (Verification): The rider arrives at the customer's door. The customer gives the
rider a code (OTP). You must verify this code before handing over the package.
o Use Endpoint: GET /verify-otp
• Step D (Completion): If the OTP is correct, the rider hands over the package.
o Use Endpoint: POST /change-shipment-status
o Status to send: "Received by Customer"
Flow 3: Returns (Failure & Reverse Logistics)
Sometimes the customer isn't home, or they reject the order.
• Scenario A (Delivery Failed): If the rider is at the customer's location but the delivery
fails.
o Use Endpoint: POST /change-shipment-status
o Status to send: "Customer Not Found" OR "Customer Not Accepted"
o (The rider then takes the parcel back to the branch).
• Scenario B (Returning to Merchant): Later, the Branch needs to send that failed parcel
back to the original Merchant.
o Step 1 (See Tasks): The rider checks for return jobs.
▪ Use Endpoint: GET /branch-to-merchant-return
o Step 2 (Pickup Return): The rider picks up the return parcel from the Branch.
▪ Use Endpoint: POST /change-shipment-status
▪ Status to send: "Rider return to merchant"
o Step 3 (Drop off Return): The rider hands the parcel back to the Merchant.
▪ Use Endpoint: POST /change-shipment-status
▪ Status to send: "Returned to merchant"



-- 


this is rdierlogrequest
  public class RiderLogRequestModel
    {
        [Required]
        public string fk_MerchantOrderId { get; set; } = string.Empty;
        [Required]
        public int fk_StatusId { get; set; }
        [Required]
        public int fk_ToEntityTypeId { get; set; }
        public string? fk_ToEntityId { get; set; } = null;
        [Required]
        public string? fk_RiderId { get; set; } = null;
        [Required]
        public string ToEntityName { get; set; }= string.Empty;
        [Required]
        public string ToEntityId { get; set; }=string.Empty;
      
    }
}


------------------------------------
branch to customer response public class BrnToCstResponseModel
    {
        public string pk_MerchantOrderId { get; set; } = string.Empty;
        public string fk_MerchantId { get; set; } = string.Empty;
        public string OrderReferenceNumber { get; set; } = string.Empty;
        public string ShipmentDescription { get; set; } = string.Empty;

        public int OrderQuantity { get; set; }
        public decimal OrderWeight { get; set; }
        public decimal OrderLength { get; set; }
        public decimal OrderHeight { get; set; }
        public decimal OrderWidth { get; set; }

        public string SpecialInstructions { get; set; } = string.Empty;
        public bool IsFragile { get; set; }
        public DateTime OrderDate { get; set; }

        public string FromEntityName { get; set; } = string.Empty;
        public string ToEntityName { get; set; } = string.Empty;
        public DateTime EventDateTime { get; set; }

        public string ReceiverCity { get; set; } = string.Empty;
        public decimal OrderAmount { get; set; }
        public string ReceiverName { get; set; } = string.Empty;
        public string ReceiverContactNumber { get; set; } = string.Empty;
        public string DeliveryAddress { get; set; } = string.Empty;
        public string DeliveryLandmark { get; set; } = string.Empty;
        public string PaymentMethod { get; set; } = string.Empty;
        public bool IsReturnable { get; set; }
        public string fk_FromEntityId { get; set; }
        public int fk_ShipmentStatusId { get; set; }
    }

}
----------------------------------------------------------------------
