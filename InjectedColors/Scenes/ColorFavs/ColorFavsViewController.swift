//
//  ColorFavsViewController.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import UIKit

class ColorFavsViewController: UIViewController, StoryOnboardable {
    
    @IBOutlet weak var colorFavsList: UITableView!
    
    @ScopedInjection var colorFavsViewModel: ColorFavsViewModel
    let viewModelToken = InjectableServices.token(for: ColorFavsViewModel.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        colorFavsList.delegate = self
        colorFavsViewModel.configureDataSource(with: colorFavsList)
    }
    
    @IBAction func createFavColor(_ sender: Any) {
        let controller = ColorSaveViewController.create()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - TableView Methods
extension ColorFavsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard
            let dataSource = colorFavsViewModel.dataSource,
            let color = dataSource.itemIdentifier(for: indexPath)
            else { return }
        
        let controller = ColorEditViewController.create()
        controller.colorViewModel.assignColor(color)
        navigationController?.pushViewController(controller, animated: true)
    }

}
