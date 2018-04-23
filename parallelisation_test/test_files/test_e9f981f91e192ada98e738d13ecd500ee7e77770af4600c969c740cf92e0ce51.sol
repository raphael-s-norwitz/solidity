pragma solidity ^0.4.8;

import "ethlanceDB.sol";
import "userLibrary.sol";
import "jobLibrary.sol";
import "sharedLibrary.sol";
import "invoiceLibrary.sol";
import "messageLibrary.sol";

library ContractLibrary {

    //    status:
    //    1: invited, 2: pending proposal, 3: accepted, 4: finished, 5: cancelled

    function addInvitation(
        address db,
        address senderId,
        uint jobId,
        address freelancerId,
        string description
    )
        internal returns (uint contractId)
    {
        var employerId = JobLibrary.getEmployer(db, jobId);
        if (senderId != employerId) throw;
        if (employerId == freelancerId) throw;
        if (getContract(db, freelancerId, jobId) != 0) throw;
        if (JobLibrary.getStatus(db, jobId) != 1) throw;
        if (!UserLibrary.isFreelancerAvailable(db, freelancerId)) throw;
        if (!UserLibrary.hasStatus(db, freelancerId, 1)) throw;

        contractId = SharedLibrary.createNext(db, "contract/count");
        setFreelancerJobIndex(db, contractId, freelancerId, jobId);
        
        EthlanceDB(db).setStringValue(sha3("invitation/description", contractId), description);
        EthlanceDB(db).setUIntValue(sha3("invitation/created-on", contractId), now);
        setStatus(db, contractId, 1);
        UserLibrary.addFreelancerContract(db, freelancerId, contractId);
        UserLibrary.addEmployerContract(db, employerId, contractId);
        JobLibrary.addContract(db, jobId, contractId);

        return contractId;
    }
    
    function addProposal(
        address db,
        uint jobId,
        address freelancerId,
        string description,
        uint rate
    )
        internal returns (uint contractId)
    {
        var employerId = JobLibrary.getEmployer(db, jobId);
        require(employerId != 0x0);
        require(freelancerId != employerId);
        require(JobLibrary.getStatus(db, jobId) == 1);
        contractId = getContract(db, freelancerId, jobId);
        if (contractId == 0) {
            contractId = SharedLibrary.createNext(db, "contract/count");
            UserLibrary.addFreelancerContract(db, freelancerId, contractId);
            UserLibrary.addEmployerContract(db, employerId, contractId);
            JobLibrary.addContract(db, jobId, contractId);
        } else if (getProposalCreatedOn(db, contractId) != 0) throw;
        
        setFreelancerJobIndex(db, contractId, freelancerId, jobId);
        EthlanceDB(db).setUIntValue(sha3("proposal/rate", contractId), rate);
        EthlanceDB(db).setUIntValue(sha3("proposal/created-on", contractId), now);
        EthlanceDB(db).setStringValue(sha3("proposal/description", contractId), description);
        setStatus(db, contractId, 2);

        return contractId;
    }

    function addContract(
        address db,
        address senderId,
        uint contractId,
        string description,
        bool isHiringDone
    )
        internal
    {
        var jobId = getJob(db, contractId);
        var freelancerId = getFreelancer(db, contractId);
        var employerId = JobLibrary.getEmployer(db, jobId);
        require(employerId != 0x0);
        require(senderId == employerId);
        require(senderId != freelancerId);
        require(getStatus(db, contractId) == 2);
        require(JobLibrary.getStatus(db, jobId) == 1);

        EthlanceDB(db).setUIntValue(sha3("contract/created-on", contractId), now);
        EthlanceDB(db).setStringValue(sha3("contract/description", contractId), description);
        setStatus(db, contractId, 3);
        if (isHiringDone) {
            JobLibrary.setHiringDone(db, jobId, senderId);
        }
    }

    function cancelContract(
        address db,
        address senderId,
        uint contractId,
        string description
    )
        internal
    {
        var freelancerId = getFreelancer(db, contractId);
        require(senderId == freelancerId);
        require(getStatus(db, contractId) == 3);
        require(getInvoicesCount(db, contractId) == 0);
        EthlanceDB(db).setUIntValue(sha3("contract/cancelled-on", contractId), now);
        EthlanceDB(db).setStringValue(sha3("contract/cancel-description", contractId), description);
        setStatus(db, contractId, 5);
    }

    function addFeedback(address db, uint contractId, address senderId, string feedback, uint8 rating) internal {
        var freelancerId = getFreelancer(db, contractId);
        var employerId = getEmployer(db, contractId);
        var status = getStatus(db, contractId);
        var jobId = getJob(db, contractId);
        if (senderId != freelancerId && senderId != employerId) throw;
        if ((status != 3) && (status != 4)) throw;
        if (JobLibrary.getStatus(db, jobId) == 3) throw;
        if (getInvoicesCount(db, contractId) == 0) throw;

        if (status == 3) {
            setStatus(db, contractId, 4);
            EthlanceDB(db).setUIntValue(sha3("contract/done-on", contractId), now);
        }

        if (senderId == freelancerId) {
            if (getFreelancerFeedbackOn(db, contractId) != 0) throw;
            EthlanceDB(db).setBooleanValue(sha3("contract/done-by-freelancer?", contractId), true);
            addFreelancerFeedback(db, contractId, employerId, feedback, rating);
        } else {
            if (getEmployerFeedbackOn(db, contractId) != 0) throw;
            addEmployerFeedback(db, contractId, freelancerId, feedback, rating);
        }
    }

    function addUserFeedback(address db, uint contractId, address receiverId, string feedbackKey,
        string ratingKey, string dateKey, string ratingsCountKey, string avgRatingKey, string description,
        uint8 rating)
    internal {
        EthlanceDB(db).setStringValue(sha3(feedbackKey, contractId), description);
        EthlanceDB(db).setUInt8Value(sha3(ratingKey, contractId), rating);
        EthlanceDB(db).setUIntValue(sha3(dateKey, contractId), now);
        UserLibrary.addToAvgRating(db, receiverId, ratingsCountKey, avgRatingKey, rating);
    }

    function addFreelancerFeedback(address db, uint contractId, address receiverId, string description, uint8 rating
    )
        internal
    {
        addUserFeedback(db, contractId, receiverId, "contract/freelancer-feedback",
            "contract/freelancer-feedback-rating", "contract/freelancer-feedback-on", "employer/ratings-count",
            "employer/avg-rating", description, rating);
    }

    function addEmployerFeedback(address db, uint contractId, address receiverId, string description, uint8 rating
    )
        internal
    {
        addUserFeedback(db, contractId, receiverId, "contract/employer-feedback",
            "contract/employer-feedback-rating", "contract/employer-feedback-on", "freelancer/ratings-count",
            "freelancer/avg-rating", description, rating);
    }

    function addMessage(address db, uint contractId, uint messageId) internal {
        SharedLibrary.addIdArrayItem(db, contractId, "contract/messages", "contract/messages-count", messageId);
    }

    function getMessages(address db, uint contractId) internal returns(uint[]) {
        return SharedLibrary.getIdArray(db, contractId, "contract/messages", "contract/messages-count");
    }

    function getOtherContractParticipant(address db, uint contractId, address user)
        internal returns (address, bool)
    {
        var freelancerId = getFreelancer(db, contractId);
        var employerId = getEmployer(db, contractId);
        require(user == freelancerId || user == employerId);
        if (user == freelancerId) {
            return (employerId, true);
        } else {
            return (freelancerId, false);
        }
    }

    function addTotalInvoiced(address db, uint contractId, uint amount) internal {
        EthlanceDB(db).addUIntValue(sha3("contract/total-invoiced", contractId), amount);
    }

    function subTotalInvoiced(address db, uint contractId, uint amount) internal {
        EthlanceDB(db).subUIntValue(sha3("contract/total-invoiced", contractId), amount);
    }

    function addInvoice(address db, uint contractId, uint invoiceId, uint amount) internal {
        SharedLibrary.addIdArrayItem(db, contractId, "contract/invoices", "contract/invoices-count", invoiceId);
        addTotalInvoiced(db, contractId, amount);
    }

    function getInvoices(address db, uint contractId) internal returns(uint[]) {
        return SharedLibrary.getIdArray(db, contractId, "contract/invoices", "contract/invoices-count");
    }

    function getInvoicesCount(address db, uint contractId) internal returns(uint) {
        return SharedLibrary.getIdArrayItemsCount(db, contractId, "contract/invoices-count");
    }

    function getInvoicesByStatus(address db, uint contractId, uint8 invoiceStatus) internal returns(uint[]) {
        var args = new uint[](1);
        args[0] = invoiceStatus;
        return SharedLibrary.filter(db, InvoiceLibrary.statusPred, getInvoices(db, contractId), args);
    }

    function getInvoices(address db, uint[] contractIds) internal returns(uint[] invoiceIds) {
        uint k = 0;
        uint totalCount = getTotalInvoicesCount(db, contractIds);
        invoiceIds = new uint[](totalCount);
        for (uint i = 0; i < contractIds.length ; i++) {
            var contractInvoiceIds = getInvoices(db, contractIds[i]);
            for (uint j = 0; j < contractInvoiceIds.length ; j++) {
                invoiceIds[k] = contractInvoiceIds[j];
                k++;
            }
        }
    }

    function getTotalInvoicesCount(address db, uint[] contractIds) internal returns(uint) {
        uint total;
        for (uint i = 0; i < contractIds.length ; i++) {
            total += getInvoicesCount(db, contractIds[i]);
        }
        return total;
    }

    function addTotalPaid(address db, uint contractId, uint amount) internal {
        EthlanceDB(db).addUIntValue(sha3("contract/total-paid", contractId), amount);
    }

    function getTotalPaid(address db, uint contractId) internal returns (uint) {
        return EthlanceDB(db).getUIntValue(sha3("contract/total-paid", contractId));
    }

    function getFreelancer(address db, uint contractId) internal returns (address) {
        return EthlanceDB(db).getAddressValue(sha3("contract/freelancer", contractId));
    }

    function getEmployer(address db, uint contractId) internal returns (address) {
        var jobId = getJob(db, contractId);
        return JobLibrary.getEmployer(db, jobId);
    }

    function getJob(address db, uint contractId) internal returns(uint) {
        return EthlanceDB(db).getUIntValue(sha3("contract/job", contractId));
    }

    function setStatus(address db, uint contractId, uint8 status) internal {
        EthlanceDB(db).setUInt8Value(sha3("contract/status", contractId), status);
    }

    function getStatus(address db, uint contractId) internal returns (uint8) {
        return EthlanceDB(db).getUInt8Value(sha3("contract/status", contractId));
    }

    function getFreelancerFeedbackOn(address db, uint contractId) internal returns(uint) {
        return EthlanceDB(db).getUIntValue(sha3("contract/freelancer-feedback-on", contractId));
    }

    function getEmployerFeedbackOn(address db, uint contractId) internal returns(uint) {
        return EthlanceDB(db).getUIntValue(sha3("contract/employer-feedback-on", contractId));
    }

    function getProposalCreatedOn(address db, uint contractId) internal returns(uint) {
        return EthlanceDB(db).getUIntValue(sha3("proposal/created-on", contractId));
    }

    function getInvitationCreatedOn(address db, uint contractId) internal returns(uint) {
        return EthlanceDB(db).getUIntValue(sha3("invitation/created-on", contractId));
    }
    
    function getContract(address db, address freelancerId, uint jobId) internal returns (uint) {
        return EthlanceDB(db).getUIntValue(sha3("contract/freelancer+job", freelancerId, jobId));
    }

    function getContracts(address db, address[] freelancerIds, uint jobId) internal returns (uint[] result) {
        result = new uint[](freelancerIds.length);
        for (uint i = 0; i < freelancerIds.length ; i++) {
            result[i] = getContract(db, freelancerIds[i], jobId);
        }
        return result;
    }

    function getRate(address db, uint contractId) internal returns(uint) {
        return EthlanceDB(db).getUIntValue(sha3("proposal/rate", contractId));
    }

    function statusPred(address db, uint[] args, uint contractId) internal returns(bool) {
        var status = getStatus(db, contractId);
        return args[0] == 0 || status == args[0];
    }

    function notContractPred(address db, address[] args, uint jobId) internal returns(bool) {
        return getContract(db, args[0], jobId) == 0;
    }
    
    function setFreelancerJobIndex(address db, uint contractId, address freelancerId, uint jobId) internal {
        EthlanceDB(db).setAddressValue(sha3("contract/freelancer", contractId), freelancerId);
        EthlanceDB(db).setUIntValue(sha3("contract/job", contractId), jobId);
        EthlanceDB(db).setUIntValue(sha3("contract/freelancer+job", freelancerId, jobId), contractId);
    }
}