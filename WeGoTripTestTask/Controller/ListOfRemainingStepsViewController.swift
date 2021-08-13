import UIKit

class ListOfRemainingStepsViewController: SwipeDownViewController {

    var tour: Tour
    var currentStep: Int
    
    @IBOutlet var listOfSteps: UITableView!
    
    init?(coder: NSCoder, tour: Tour, currentStep: Int) {
        self.tour = tour
        self.currentStep = currentStep
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        listOfSteps.dataSource = self
        listOfSteps.delegate = self
    }

    @IBAction func closeList(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension ListOfRemainingStepsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tour.steps.count - currentStep
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as! RemainingStepTableViewCell
        let step = tour.steps[indexPath.row + currentStep]
        
        cell.numberLabel?.text = "\(indexPath.row + currentStep + 1)/\(tour.steps.count)"
        cell.titleLabel?.text = step.title

        return cell
    }
    
    
}
