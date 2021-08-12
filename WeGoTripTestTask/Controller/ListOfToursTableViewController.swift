import UIKit

class ListOfToursTableViewController: UITableViewController {
    
    var tours = [Tour]()
    let networkController = NetworkController()
    let indicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        self.networkController.fetchTours { (result) in
            switch result {
            case .success(let tours):
                self.tours = tours
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.indicator.removeFromSuperview()
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tours.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TourCell", for: indexPath)
        let tour = tours[indexPath.row]
        
        cell.textLabel?.text = tour.title

        return cell
    }

    @IBSegueAction func showStepsList(_ coder: NSCoder, sender: Any?) -> ListOfStepsTableViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell)  else { return nil }
        
        let tour = tours[indexPath.row]
        
        return ListOfStepsTableViewController(coder: coder, tour: tour)
    }
    
}
