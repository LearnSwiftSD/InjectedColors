import UIKit
import PlaygroundSupport

extension Arborist: LoggingService {}

class FirstViewController: UIViewController {
    
    var logger: LoggingService!
    
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
        anotherController.logger = Arborist()
        present(anotherController, animated: true)
    }
    
}

class SecondViewController: UIViewController {
    
    var logger: LoggingService!
    
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
viewController.logger = Arborist()

PlaygroundPage.current.liveView = viewController
