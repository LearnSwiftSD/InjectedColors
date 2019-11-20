import UIKit
import PlaygroundSupport

// MARK: - Show protocol only based dependency injection


class FirstViewController: UIViewController {
    
    private let logger = Arborist()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug(
            tag: "Hey There",
            message: "Hello",
            loc: LocData(self)
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.error(
            tag: nil,
            message: "It Blew Up dude",
            loc: LocData(self)
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showNewScreen()
    }
    
    func showNewScreen() {
        let anotherController = SecondViewController()
        present(anotherController, animated: true)
    }
    
}

class SecondViewController: UIViewController {
    
    private let logger = Arborist()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.green
        
        logger.info(
            tag: "Hey You!!!",
            message: "Hello",
            loc: LocData(self)
        )
    }
    
    deinit {
        logger.info(tag: "Good Bye", message: "Being Deinitialized", loc: LocData(self))
    }
    
}

let viewController = FirstViewController()

PlaygroundPage.current.liveView = viewController


