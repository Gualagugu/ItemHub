//
//  ChatViewController.swift
//  2020SummerProj
//
//  Created by 薛凡 on 6/29/20.
//  Copyright © 2020 香槟最靓的仔. All rights reserved.
//

//import UIKit
//import MessageKit
//
//struct Sender:SenderType {
//
//    var senderId: String
//
//    var displayName: String
//
//}
//
//struct Message: MessageType {
//
//    var sender: SenderType
//
//    var messageId: String
//
//    var sentDate: Date
//
//    var kind: MessageKind
//
//}
//
//
//class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
//
//    let currentUser = Sender(senderId: "self", displayName: "Gabby")
//
//    let otherUser = Sender(senderId: "other", displayName: "Arya Stark")
//
//    var messages = [MessageType]()
//
//    override func viewDidLoad() {
//
//        super.viewDidLoad()
//
//        messages.append(Message(sender: currentUser,
//                                messageId: "1",
//                                sentDate: Date().addingTimeInterval(-8000),
//                                kind: .text("Hey there, I'm Gabby ;)")))
//
//        messages.append(Message(sender: otherUser,
//                                messageId:"2",
//                                sentDate: Date().addingTimeInterval(-7000),
//                                kind: .text("Hi Gabby, I'm Arya.")))
//
//        messages.append(Message(sender: otherUser,
//                                       messageId:"3",
//                                       sentDate: Date().addingTimeInterval(-6000),
//                                       kind: .text("Valar morghulis")))
//
//        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-5000), kind: .text("Valar dohaeris")))
//
//
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//
//    }
//
//    func currentSender() -> SenderType {
//        return currentUser
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages[indexPath.section]
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//
//
//}

//import UIKit
//import InputBarAccessoryView
//import Firebase
//import MessageKit
//import FirebaseFirestore
//import SDWebImage
//
//class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
//
//    var currentUser = Auth.auth().currentUser!
//
//    var user2Name: String?
//    var user2ImgUrl: String?
//    var user2UID: String?
//
//    private var docReference: DocumentReference?
//
//    var messages: [Message] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
////        user2Name = "\()"
//
//        self.title = user2Name ?? "Chat"
//
//        navigationItem.largeTitleDisplayMode = .never
//        maintainPositionOnKeyboardFrameChanged = true
//        messageInputBar.inputTextView.tintColor = .blue
//        messageInputBar.sendButton.setTitleColor(.blue, for: .normal)
//
//        messageInputBar.delegate = self
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//
//        loadChat()
//
//    }
//
//    // MARK: - Custom messages handlers
//
//    func createNewChat() {
//        let users = [self.currentUser.uid, self.user2UID]
//         let data: [String: Any] = [
//             "users":users
//         ]
//
//         let db = Firestore.firestore().collection("Chats")
//         db.addDocument(data: data) { (error) in
//             if let error = error {
//                 print("Unable to create chat! \(error)")
//                 return
//             } else {
//                 self.loadChat()
//             }
//         }
//    }
//
//    func loadChat() {
//
//        //Fetch all the chats which has current user in it
//        let db = Firestore.firestore().collection("Chats")
//                .whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
//
//
//        db.getDocuments { (chatQuerySnap, error) in
//
//            if let error = error {
//                print("Error: \(error)")
//                return
//            } else {
//
//                //Count the no. of documents returned
//                guard let queryCount = chatQuerySnap?.documents.count else {
//                    return
//                }
//
//                if queryCount == 0 {
//                    //If documents count is zero that means there is no chat available and we need to create a new instance
//                    self.createNewChat()
//                }
//                else if queryCount >= 1 {
//                    //Chat(s) found for currentUser
//                    for doc in chatQuerySnap!.documents {
//
//                        let chat = Chat(dictionary: doc.data())
//                        //Get the chat which has user2 id
//                        if (chat?.users.contains(self.user2UID!))! {
//
//                            self.docReference = doc.reference
//                            //fetch it's thread collection
//                             doc.reference.collection("thread")
//                                .order(by: "created", descending: false)
//                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
//                            if let error = error {
//                                print("Error: \(error)")
//                                return
//                            } else {
//                                self.messages.removeAll()
//                                    for message in threadQuery!.documents {
//
//                                        let msg = Message(dictionary: message.data())
//                                        self.messages.append(msg!)
//                                        print("Data: \(msg?.content ?? "No message found")")
//                                    }
//                                self.messagesCollectionView.reloadData()
//                                self.messagesCollectionView.scrollToBottom(animated: true)
//                            }
//                            })
//                            return
//                        } //end of if
//                    } //end of for
//                    self.createNewChat()
//                } else {
//                    print("Let's hope this error never prints!")
//                }
//            }
//        }
//    }
//
//
//    private func insertNewMessage(_ message: Message) {
//
//        messages.append(message)
//        messagesCollectionView.reloadData()
//
//        DispatchQueue.main.async {
//            self.messagesCollectionView.scrollToBottom(animated: true)
//        }
//    }
//
//    private func save(_ message: Message) {
//
//        let data: [String: Any] = [
//            "content": message.content,
//            "created": message.created,
//            "id": message.id,
//            "senderID": message.senderID,
//            "senderName": message.senderName
//        ]
//
//        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
//
//            if let error = error {
//                print("Error Sending message: \(error)")
//                return
//            }
//
//            self.messagesCollectionView.scrollToBottom()
//
//        })
//    }
//
//    // MARK: - InputBarAccessoryViewDelegate
//
//            func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//
//                let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUser.uid, senderName: currentUser.displayName!)
//
//                  //messages.append(message)
//                  insertNewMessage(message)
//                  save(message)
//
//                  inputBar.inputTextView.text = ""
//                  messagesCollectionView.reloadData()
//                  messagesCollectionView.scrollToBottom(animated: true)
//            }
//
//
//    // MARK: - MessagesDataSource
//    func currentSender() -> SenderType {
//
//        return Sender(id: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser?.displayName ?? "Name not found")
//
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//
//        return messages[indexPath.section]
//
//    }
//
//    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//
//        if messages.count == 0 {
//            print("No messages to display")
//            return 0
//        } else {
//            return messages.count
//        }
//    }
//
//
//    // MARK: - MessagesLayoutDelegate
//
//    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return .zero
//    }
//
//    // MARK: - MessagesDisplayDelegate
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return isFromCurrentSender(message: message) ? .blue: .lightGray
//    }
//
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//
//        if message.sender.senderId == currentUser.uid {
//            SDWebImageManager.shared.loadImage(with: currentUser.photoURL, options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
//                avatarView.image = image
//            }
//        } else {
//            SDWebImageManager.shared.loadImage(with: URL(string: user2ImgUrl!), options: .highPriority, progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
//                avatarView.image = image
//            }
//        }
//    }
//
//    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
//        return .bubbleTail(corner, .curved)
//
//    }
//
//}



import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    var messages: [Message] = []
    var member: Member!

    override func viewDidLoad() {

        member = Member(name: "test", color: .blue)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self

    }

}

// Number and content of message
extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return Sender(senderId: member.name, displayName: member.name)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [.font: UIFont.systemFont(ofSize: 12)] )
    }

}

// Height, padding, alignment for different views
extension ChatViewController: MessagesLayoutDelegate {

    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

}

// Colors, style and view that define the look of the message
extension ChatViewController: MessagesDisplayDelegate {

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let message = messages[indexPath.section]
        let color = message.member.color
        avatarView.backgroundColor = color
    }

}

// Sending and typing new messages
extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        let newMessage = Message(member: member, text: text, messageId: UUID().uuidString)

        messages.append(newMessage)
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
    }

}
