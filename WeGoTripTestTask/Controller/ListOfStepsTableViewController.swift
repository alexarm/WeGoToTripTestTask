import UIKit

class ListOfStepsTableViewController: UITableViewController {
    
    var tour: Tour
    
    init?(coder: NSCoder, tour: Tour) {
        self.tour = tour
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tour.steps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)
        let step = tour.steps[indexPath.row]
        
        cell.textLabel?.text = step.title

        return cell
    }

    @IBSegueAction func showStep(_ coder: NSCoder, sender: Any?) -> MainScreenViewController? {
        guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell)  else { return nil }
        
        let chosenStepNumber = indexPath.row
        
        return MainScreenViewController(coder: coder, tour: tour, stepNumber: chosenStepNumber)
    }
    
}
