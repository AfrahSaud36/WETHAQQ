import CloudKit

struct PersonalInfoModel {
    var name: String
    var email: String
    var bio: String
    var userID: String
    var recordID: CKRecord.ID

    init(record: CKRecord) {
        self.name = record["name"] as? String ?? ""
        self.email = record["email"] as? String ?? ""
        self.bio = record["bio"] as? String ?? ""
        self.userID = record["userID"] as? String ?? ""
        self.recordID = record.recordID
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "UserProfile", recordID: self.recordID)
        record["name"] = self.name as CKRecordValue
        record["email"] = self.email as CKRecordValue
        record["bio"] = self.bio as CKRecordValue
        record["userID"] = self.userID as CKRecordValue
        return record
    }
}


