struct KlarnaPostPurchaseErrorWrapper: Encodable {
    public let name: String
    public let message: String
    public let isFatal: Bool
    public let status: String?
}
