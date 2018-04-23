/*
WeiFund v1.0

This contract creates a crowdfunding platform. Start, donate to, payout and 
refund crowdfunding campaigns on Ethereum.

If the campaign goal is reached or surpassed by stated expiry, all raised 
funds will be paid out to the campaign's beneficiary. If the campaign goal is 
not reached by the stated expiry, all funds are refundable back to oringial 
contributors. Campaigns may also select a configuration contract which can 
be used for customized outward extensibility of campaigns to contracts like 
token or registry systems.

Multiple contributions by the same account are allowed. Each contribution will
be treated as it's own contribution instance.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <http://unlicense.org>
*/

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
contract WeiFundInterface {
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
	
    /// @notice Is the campaign an active campaign (i.e. hasnt failed, succeeded or been paid out)
    /// @dev Returns a boolean, is the campaign active or not
    /// @param _campaignID (campaign id) The campaign id
    /// @return is the campaign active or not (boolean)
    function isActive(uint _campaignID) constant returns (bool) {}
    
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

/// @title WeiFund - A Decentralized Crowdfunding Platform
/// @author Nick Dodson <thenickdodson@gmail.com>
contract WeiFund is WeiFundInterface {
    // @notice Operator; A user is an account that has started campaigns on WeiFund
    // @dev This object stores all pertinant campaign operator data, such as how many campaigns the operator has started, and the campaign ID's of all the campaigns they have or are operating
    struct Operator {
        uint numCampaigns;
        mapping(uint => uint) campaigns;
    }
    
    // @notice Contribution; This object helps store the contribution data
    // @dev This object stores the contributor data, such as the contributor address, and amount
    struct Contribution {
        address contributor;
        address beneficiary;
        uint amountContributed;
        bool refunded;
        uint created;
    }
    
    // @notice Campaign; The crowdfunding campaign object
    // @dev This object stores all the pertinant campaign data, such as: the name, beneificary, fundingGoal, and the funder data
    struct Campaign {
        string name;
        address owner;
        address beneficiary;
        address config;
        bool paidOut;
        uint expiry;
        uint fundingGoal;
        uint amountRaised;
        uint created;
        uint numContributions;
        mapping (uint => Contribution) contributions;
        mapping (address => uint[]) toContribution;
    }
    
    /// @notice version; The current version of the WeiFund contract
    /// @dev This is the version value of this WeiFund contract
    uint public version = 1;
  
    /// @notice numCampaigns; The total number of crowdfunding campaigns started on WeiFund
    /// @dev This is the uint store that contains the number of the total amount of all crowdfunding campaigns started on WeiFund. This is also used to generate campaign ID numbers.
    uint public numCampaigns;
    
    /// @notice Campaigns (the campaign ID); Get the campaign data at the specified campaign ID
    /// @dev This data store maps campaign ID's to stored Campaign objects. With this method you can access any crowdfunding campaign started on WeiFund.
    mapping (uint => Campaign) public campaigns;
    
    /// @notice Operators (the user address); Get the number of campaigns a user has started
    /// @dev This will return a user object that contains the number of campaigns a user has started. Use the userCampaigns method to the ID's to the crowdfunding campaigns that they have started.
    mapping (address => Operator) public operators;
    
    function newCampaign(string _name, address _beneficiary, uint _fundingGoal, uint _expiry, address _config) public returns (uint campaignID) {
        if(_fundingGoal <= 0 || _expiry <= now)
            throw;
            
        campaignID = numCampaigns++;
        Campaign c = campaigns[campaignID];
        c.name = _name;
        c.owner = msg.sender;
        c.beneficiary = _beneficiary;
        c.fundingGoal = _fundingGoal;
        c.expiry = _expiry;
        c.created = now;
        c.config = _config;
        
        Operator u = operators[msg.sender];
        uint u_campaignID = u.numCampaigns++;
        u.campaigns[u_campaignID] = campaignID;
        
        CampaignCreated(campaignID, msg.sender);
        
        if(c.config != address(0))
            WeiFundConfig(c.config).newCampaign(campaignID, msg.sender, _fundingGoal);
    }
    
    function contribute(uint _campaignID, address _beneficiary) public returns (uint contributionID) {
        Campaign c = campaigns[_campaignID];
        
        if(now > c.expiry || msg.value == 0)
            throw;
            
        contributionID = c.numContributions++;
        Contribution donation = c.contributions[contributionID];
        donation.amountContributed += msg.value;
        donation.beneficiary = _beneficiary;
        donation.contributor = msg.sender;
        donation.created = now;
        c.amountRaised += donation.amountContributed;
        c.toContribution[msg.sender].push(contributionID);
        Contributed(_campaignID, msg.sender, c.amountRaised);
        
        if(c.config != address(0))
            WeiFundConfig(c.config).contribute(_campaignID, msg.sender, _beneficiary, msg.value);
    }
    
    function refund(uint _campaignID, uint contributionID) public {
        Campaign c = campaigns[_campaignID];
        
        if (!hasFailed(_campaignID))
            throw;
            
        Contribution donation = c.contributions[c.toContribution[msg.sender][contributionID]];
        
        if(donation.amountContributed <= 0 || donation.refunded)
            throw;
			
		address receiver = donation.contributor;
		
		if(donation.beneficiary != address(0))
			receiver = donation.beneficiary;
        
        receiver.send(donation.amountContributed);
        donation.refunded = true;
        Refunded(_campaignID, receiver, donation.amountContributed);
    
        if(c.config != address(0))
            WeiFundConfig(c.config).refund(_campaignID, donation.contributor, donation.amountContributed);
    }
  
    function payout(uint _campaignID) public {
        Campaign c = campaigns[_campaignID];
        
        if(!isSuccess(_campaignID) || c.paidOut)
            throw;
        
        c.beneficiary.send(c.amountRaised);
        c.paidOut = true;
        PaidOut(_campaignID, msg.sender, c.amountRaised);
        
        if(c.config != address(0))
            WeiFundConfig(c.config).payout(_campaignID, c.amountRaised);
    }
    
    function operatorCampaignID(address _operator, uint _campaignIndex) public constant returns (uint) {
        Operator u = operators[_operator];
        
        return u.campaigns[_campaignIndex];
    }
    
    function totalCampaignsBy(address _operator) constant returns (uint) {
        Operator u = operators[_operator];
        
        return u.numCampaigns;
    }
    
    function totalCampaigns() constant returns (uint) {
        return numCampaigns;
    }
    
    function contributionAt(uint _campaignID, uint _contributionID) public constant returns (address contributor, 
                                                                                            address beneficiary, 
                                                                                            uint amountContributed, 
                                                                                            bool refunded,
                                                                                            uint created) {
        Campaign c = campaigns[_campaignID];
        
        return (c.contributions[_contributionID].contributor,
                c.contributions[_contributionID].beneficiary,
                c.contributions[_contributionID].amountContributed,
                c.contributions[_contributionID].refunded
                c.contributions[_contributionID].created);
    }
    
    function contributionID(uint _campaignID, address _contributor, uint _contributionIndex) public constant returns (uint) {
        Campaign c = campaigns[_campaignID];
        
        return c.toContribution[_contributor][_contributionIndex];
    }
    
    function totalContributionsBy(uint _campaignID, address _contributor) public constant returns (uint) {
        Campaign c = campaigns[_campaignID];
        
        return c.toContribution[_contributor].length;
    }
    
    function isContributor(uint _campaignID, address _contributor) public constant returns (bool) {
        Campaign c = campaigns[_campaignID];
        
        if(c.contributions[c.toContribution[_contributor][0]].amountContributed != 0)
            return true;
    }
    
    function ownerOf(uint _campaignID) public constant returns (address){
        Campaign c = campaigns[_campaignID];
        
        return c.owner;
    }
    
    function beneficiaryOf(uint _campaignID) public constant returns (address){
        Campaign c = campaigns[_campaignID];
        
        return c.beneficiary;
    }
    
    function configOf(uint _campaignID) public constant returns (address){
        Campaign c = campaigns[_campaignID];
        
        return c.config;
    }
    
    function amountRaisedBy(uint _campaignID) public constant returns (uint){
        Campaign c = campaigns[_campaignID];
        
        return c.amountRaised;
    }
    
    function fundingGoalOf(uint _campaignID) public constant returns (uint){
        Campaign c = campaigns[_campaignID];
        
        return c.fundingGoal;
    }
    
    function expiryOf(uint _campaignID) public constant returns (uint){
        Campaign c = campaigns[_campaignID];
        
        return c.expiry;
    }
    
    function createdAt(uint _campaignID) public constant returns (uint){
        Campaign c = campaigns[_campaignID];
        
        return c.created;
    }
    
    function totalContributions(uint _campaignID) public constant returns (uint){
        Campaign c = campaigns[_campaignID];
        
        return c.numContributions;
    }
    
    function isOwner(uint _campaignID, address _owner) public constant returns (bool){
        Campaign c = campaigns[_campaignID];
        
        if(c.owner == _owner)
            return true;
    }
    
    function hasFailed(uint _campaignID) public constant returns (bool){
        Campaign c = campaigns[_campaignID];
        
        if (now > c.expiry
            && c.amountRaised < c.fundingGoal 
            && c.amountRaised > 0)
            return true;
    }
    
    function isSuccess(uint _campaignID) public constant returns (bool){
        Campaign c = campaigns[_campaignID];
        
        if (c.amountRaised >= c.fundingGoal)
            return true;
    }
    
    function isPaidOut(uint _campaignID) public constant returns (bool){
        Campaign c = campaigns[_campaignID];
        
        return c.paidOut;
    }
    
	// new method not imp. yet
    function isActive(uint _campaignID) public constant returns (bool){
        if(!isSuccess(_campaignID)
			&& !isPaidOut(_campaignID)
			&& !hasFailed(_campaignID))
			return true;
    }
    
    function totalRefunded(uint _campaignID) public constant returns (uint){
        Campaign c = campaigns[_campaignID];
        uint refunded = 0;
        
        if(!hasFailed(_campaignID))
            return 0;
        
        for(uint contributionID = 0; contributionID < c.numContributions; contributionID++) {
            if(c.contributions[contributionID].refunded == true)
                refunded += c.contributions[contributionID].amountContributed;
        }
        
        return refunded;
    }
    
    function isRefunded(uint _campaignID) public constant returns (bool){
        Campaign c = campaigns[_campaignID];
		
		if(c.numContributions == 0)
			return false;
        
        for(uint contributionID = 0; contributionID < c.numContributions; contributionID++) {
            if(c.contributions[contributionID].refunded != true)
                return false;
        }
        
        return true;
    }
}