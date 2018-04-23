
/// @title The core WeiFund configuration hook interface
/// @author Nick Dodson <thenickdodson@gmail.com>
/// @dev This contract enables campaigns to interact with other contracts, such as equity dispersal mechanisms (controllers) and registries
contract WeiFundConfig {
    /// @notice Called when a new campaign has been created
    /// @dev If a campaign specifies a configuration contract, this will be called when the new campaign is created 
    /// @param _campaignID (campaign id) the campaign id
    /// @param _owner (campaign owner) the campaign owner or creator
    /// @param _fundingGoal (funding goal) the campaign funding goal
    function newCampaign(uint _campaignID, address _owner, uint _fundingGoal) {}
    
    /// @notice Called when a new contribution has been made
    /// @dev This will be called when a new contribution has been made to a campaign, this can be used for token generation
    /// @param _campaignID (campaign id) the campaign id 
    /// @param _contributor (contributor) the account that initially made the campaign contribution
    /// @param _beneficiary (contribution beneficiary) the contribution beneficiary
    /// @param _amountContributed (amount contributed) the amount contributed by the contributor
    function contribute(uint _campaignID, address _contributor, address _beneficiary, uint _amountContributed) {}
    
    /// @notice Called when a new refund has been ordered
    /// @dev This will be called when a campaign has failed and a contributor is ordering a refund of their contributed ether
    /// @param _campaignID (campaign id) the campaign id 
    /// @param _contributor (contributor) the campaign contributor address
    /// @param _amountRefunded the amount refunded to the contributor
    function refund(uint _campaignID, address _contributor, uint _amountRefunded) {}
    
    /// @notice Called when a campaign is being paid out
    /// @dev This will be called when a campaign has succeceed and the funds are being paid out to the contributor
    /// @param _campaignID (campaign id) the campaign id 
    /// @param _amountPaid The amount paid out to the campaign beneficiary
    function payout(uint _campaignID, uint _amountPaid) {}
}

/// @title The core WeiFund crowdfunding interface
/// @author Nick Dodson <thenickdodson@gmail.com>
contract WeiFund {
    /// @notice creates a new crowdfunding campaign
    /// @dev This method starts a new crowdfunding campaign and calles the campaigns configuration contract if stated
    /// @param _name (campaign name) The campaign name
    /// @param _beneficiary (beneficiary) The address of the beneficiary for this campaign
    /// @param _fundingGoal (funding goal) The funding goal of the campaign. If this goal is not met by the timelimit, all ether will be refunded to the respective contributers
    /// @param _expiry (expiry) When the campaign will expire and contributions can no longer be made
    /// @param _config (configuration address) The configuration address
    /// @return _campaignID (campaign ID) The newly created campaign ID number
    function newCampaign(string _name, address _beneficiary, uint _fundingGoal, uint _expiry, address _config) returns (uint campaignID) {}
    
    /// @notice contributes ether to a WeiFund campaign
    /// @dev This method will contribute an amount of ether to the campaign at ID _cid. All contribution data will be stored so that the issuance of digital assets can be made out to the contributor address
    /// @param _campaignID (campaign ID) The ID number of the crowdfunding campaign
    /// @param _beneficiary (contribute As Address) This allows a user to contribute on behalf of another address, if left empty, the from sender address is used as the primary Funder address
    /// @return _contributionID (contributor ID) The newly created contributor ID
    function contribute(uint _campaignID, address _beneficiary) returns (uint _contributionID) {}
    
    /// @notice refunds your accounts contribution of a failed crowdfunding campaign
    /// @dev This method will refund the amount you contributed to a WeiFund campaign, if that campaign has failed to meet it's funding goal or has expired.
    /// @param _campaignID (campaign ID) The ID number of the crowdfunding campaign to be refunded
    function refund(uint _campaignID, uint _contribution) {}
    
    /// @notice this will payout a successful crowdfunding campaign to the beneficiary address
    /// @dev This method will payout a successful WeiFund crowdfunding campaign to the beneficiary address specified. Any person can trigger the payout by calling this method.
    /// @param _campaignID (campaign ID) The ID number of the crowdfunding campaign
    function payout(uint _campaignID) {}
    
    /// @notice user Campaign ID (the address of the user, the user campaign ID); get the campaign ID of one of the users crowdfunding campaigns.
    /// @dev This method will get the campaign ID of one of the users crowdfunding campaigns, by looking up the campaign with a user campaign ID. All campaign owners and their campaigns are stored with WeiFund.
    /// @param _operator (campaign creator) The address of the campaign operator
    /// @param _campaignIndex The user campaign ID
    /// @return _campaignID (campaign ID) The campaign ID
    function operatorCampaignID(address _operator, uint _campaignIndex) constant returns (uint campaignID) {}
    
    /// @notice total number of campaigns created by a specific user
    /// @dev This method will get the campaign ID of one of the users crowdfunding campaigns, by looking up the campaign with a user campaign ID. All campaign owners and their campaigns are stored with WeiFund.
    /// @param _operator (campaign creator) The user's address
    /// @return _numCampaigns (number of campaigns) The number of campaigns
    function totalCampaignsBy(address _operator) constant returns (uint numCampaigns) {}
    
    /// @notice total number of contributions made by a contributor account to a campaign
    /// @dev This method will retunr an unsigned integer of the total number of campaigns started by a single account
    /// @param _campaignID (campaign id) The campaign id
    /// @param _contributor (campaign contributor address) The user's address
    /// @return _numCampaigns (number of campaigns) The number of campaigns
    function totalContributionsBy(uint _campaignID, address _contributor) constant returns (uint) {}
    
    /// @notice the total number of campaigns on WeiFund
    /// @dev This method returns the total number of campaigns on WeiFund as an unsigned integer
    /// @return _numCampaigns (number of campaigns) The number of campaigns
    function totalCampaigns() constant returns (uint numCampaigns) {}
    
    /// @notice retrieve campaign contribution data at specified contributor ID
    /// @dev Retrieve contributor data (tuple) of a specific contributor
    /// @param _campaignID (campaign id) The address of the campaign operator.
    /// @param _contributionID (contributor id) The user campaign ID
    /// @return contributor, beneficiary, amountContributed, refunded, created
    function contributionAt(uint _campaignID, uint _contributionID) constant returns (address contributor, 
                                                                                            address beneficiary, 
                                                                                            uint amountContributed, 
                                                                                            bool refunded,
                                                                                            uint created) {}
    /// @notice When the campaign was created
    /// @dev For retrieving the campaign created UNIX timestamp integer
    /// @param _campaignID (campaign id) The campaign id
    /// @return unix timestamp when the campaign was created
    function createdAt(uint _campaignID) public constant returns (uint) {}
    
    /// @notice Retreive a contributor ID of a campaign contributor
    /// @dev The contributor ID can be used to get contributor information such as how much they contributed to a campaign
    /// @param _campaignID (campaign id) The campaign id
    /// @param _contributor (contributor address)
    /// @param _contributionIndex (contribution index)
    /// @return the contributor ID
    function contributionID(uint _campaignID, address _contributor, uint _contributionIndex) constant returns (uint) {}
    
    /// @notice Retreive the owner of a specific campaign
    /// @dev The campaign owner is the 20 byte address of the account that created the campaign
    /// @param _campaignID (campaign id) The campaign id
    /// @return The campaign owner's account
    function ownerOf(uint _campaignID) constant returns (address) {}
    
    /// @notice The beneficiary address of the campaign
    /// @dev The campaign beneficiary is the account that will receive the funds raised by the camapign
    /// @param _campaignID (campaign id) The campaign id
    /// @return The campaign beneficiary address
    function beneficiaryOf(uint _campaignID) constant returns (address) {}
    
    /// @notice The configuration contract address of the campaign
    /// @dev The configuration contract address allows campaigns to extend their functionality beyond the WeiFund contract
    /// @param _campaignID (campaign id) The campaign id
    /// @return The confirguation contract address
    function configOf(uint _campaignID) constant returns (address) {}
    
    /// @notice The amount raised by the campaign
    /// @dev The amount of ether raised by a specific campaign
    /// @param _campaignID (campaign id) The campaign id
    /// @return The campaign beneficiary address
    function amountRaisedBy(uint _campaignID) constant returns (uint) {}
    
    /// @notice The funding goal of a campaign
    /// @dev The amount of ether that needs to be raised in order for campaign funds to be released to the beneficiary, fund value is in wei
    /// @param _campaignID (campaign id) The campaign id
    /// @return The funding goal in wei
    function fundingGoalOf(uint _campaignID) constant returns (uint) {}
    
    /// @notice The campaign expiry
    /// @dev The unix timestamp at which the campaign funding goal must be reached in order for funds to be paid out
    /// @param _campaignID (campaign id) The campaign id
    /// @return The campaign expiry
    function expiryOf(uint _campaignID) constant returns (uint) {}
    
    /// @notice The total number of campaign contributors
    /// @dev The total number of campaign contributors returned as an integer
    /// @param _campaignID (campaign id) The campaign id
    /// @return The total number of campaign contributors
    function totalContributors(uint _campaignID) constant returns (uint) {}
    
    /// @notice Check to see if account is a campaign contributor
    /// @dev Determine whether a specified account address is a campaign contributor
    /// @param _campaignID (campaign id) The campaign id
    /// @param _contributor (contributor address) The contributors account address
    /// @return is address contributor or not (boolean)
    function isContributor(uint _campaignID, address _contributor) constant returns (bool) {}
    
    /// @notice Check to see if account is a campaign owner
    /// @dev Determine whether a specified account address is the campaign owner
    /// @param _campaignID (campaign id) The campaign id
    /// @param _owner (owner) The owner address
    /// @return is address the campaign owner or not (boolean)
    function isOwner(uint _campaignID, address _owner) constant returns (bool) {}
    
    /// @notice Has the campaign failed to reach its goals
    /// @dev Determine whether a campaign has failed to reach its goals
    /// @param _campaignID (campaign id) The campaign id
    /// @return has the campaign failed or not (boolean)
    function hasFailed(uint _campaignID) constant returns (bool) {}
    
    /// @notice Has the campaign succeeded in reaching its funding goals
    /// @dev Determine whether a campaign has succeeded to reach its goals by the campaign expiry
    /// @param _campaignID (campaign id) The campaign id
    /// @return has the campaign succeeded or not (boolean)
    function isSuccess(uint _campaignID) constant returns (bool) {}
    
    /// @notice Has the campaign been paid out
    /// @dev Has the funds raised by the campaign been paid out (returns a boolean)
    /// @param _campaignID (campaign id) The campaign id
    /// @return has the campaign been paid out
    function isPaidOut(uint _campaignID) constant returns (bool) {}
    
    /// @notice The total amount of funds that have been refunded for a specified campaign
    /// @dev The total amount of ether that has been refunded for a specified campaign (funds are integers in the wei denomination)
    /// @param _campaignID (campaign id) The campaign id
    /// @return the total amount of funds refunded (an integer representing wei)
    function totalRefunded(uint _campaignID) constant returns (uint) {}
    
    /// @notice Has the campaign been completly refunded
    /// @dev Are all funds refunded from this campaign (returns a boolean)
    /// @param _campaignID (campaign id) The campaign id
    /// @return have the funds been refunded or not
    function isRefunded(uint _campaignID) constant returns (bool) {}
    
    event CampaignCreated(uint indexed _campaignID, address indexed _owner);
    event Contributed(uint indexed _campaignID, address indexed _contributor, uint _amountContributed);
    event Refunded(uint indexed _campaignID, address indexed _contributor, uint _amountRefunded);
    event PaidOut(uint indexed _campaignID, address indexed _beneficiary, uint _amountPaid);
}

/// @title The MultiService contract allows WeiFund campaigns to have multiple services called when contributions, refund and payouts are made
/// @author Nick Dodson <thenickdodson@gmail.com>
contract MultiService is WeiFundConfig {
    address weifund;
    uint campaignID;
	uint public version;
    address[] public services;
    
    modifier isWeiFund {
        if(msg.sender == weifund)
            _
    }
    
    modifier isCampaign (uint _campaignID) {
        if(_campaignID == campaignID)
            _
    }
    
    function MultiService(address _weifund, address[] _services) {
        weifund = _weifund;
        services = _services;
		version = 1;
    }
    
    function newCampaign(uint _campaignID, address _owner, uint _fundingGoal) isWeiFund {
        campaignID = _campaignID;
    }
    
    function contribute(uint _campaignID, address _contributor, address _beneficiary, uint _amountContributed) isWeiFund isCampaign(_campaignID) {
        for(uint serviceID = 0; serviceID < services.length; serviceID++)
            WeiFundConfig(services[serviceID]).contribute(_campaignID, _contributor, _beneficiary, _amountContributed);
    }
    
    function refund(uint _campaignID, address _contributor, uint _amountRefunded) isWeiFund isCampaign(_campaignID)  {
        for(uint serviceID = 0; serviceID < services.length; serviceID++)
            WeiFundConfig(services[serviceID]).refund(_campaignID, _contributor, _amountRefunded);
    }
    
    function payout(uint _campaignID, uint _amountPaid) isWeiFund isCampaign(_campaignID)  {
        for(uint serviceID = 0; serviceID < services.length; serviceID++)
            WeiFundConfig(services[serviceID]).payout(_campaignID, _amountPaid);
    }
}