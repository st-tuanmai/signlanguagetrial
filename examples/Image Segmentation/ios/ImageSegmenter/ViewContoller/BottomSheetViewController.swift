// Copyright 2024 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// =============================================================================

import UIKit

protocol BottomSheetViewControllerDelegate: AnyObject {
  /**
   This method is called when the user opens or closes the bottom sheet.
  **/
  func viewController(
    _ viewController: BottomSheetViewController,
    didSwitchBottomSheetViewState isOpen: Bool)
}

/** The view controller is responsible for presenting the controls to change the meta data for the image segmenter and updating the singleton`` DetectorMetadata`` on user input.
 */
class BottomSheetViewController: UIViewController {

  enum Action {
    case changeModel(Model)
    case changeBottomSheetViewBottomSpace(Bool)
  }

  // MARK: Delegates
  weak var delegate: BottomSheetViewControllerDelegate?

  // MARK: Storyboards Connections
  @IBOutlet weak var inferenceTimeNameLabel: UILabel!
  @IBOutlet weak var inferenceTimeLabel: UILabel!
  @IBOutlet weak var choseModelButton: UIButton!
  @IBOutlet weak var toggleBottomSheetButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }

  // MARK: - Private function
  private func setupUI() {
    // Choose model option
    let selectedModelAction = {(action: UIAction) in
      self.updateModel(modelTitle: action.title)
    }
    // Model acctions
    let actions: [UIAction] = Model.allCases.compactMap { model in
      return UIAction(
        title: model.name,
        state: (InferenceConfigurationManager.sharedInstance.model == model) ? .on : .off,
        handler: selectedModelAction
      )
    }
    choseModelButton.menu = UIMenu(children: actions)
    choseModelButton.showsMenuAsPrimaryAction = true
    choseModelButton.changesSelectionAsPrimaryAction = true
  }

  private func updateModel(modelTitle: String) {
    guard let model = Model(name: modelTitle) else {
      return
    }
    InferenceConfigurationManager.sharedInstance.model = model
  }

  // MARK: - Public Functions
  func update(inferenceTimeString: String) {
    inferenceTimeLabel.text = inferenceTimeString
  }

  // MARK: IBAction
  @IBAction func expandButtonTouchUpInside(_ sender: UIButton) {
    sender.isSelected.toggle()
    inferenceTimeLabel.isHidden = !sender.isSelected
    inferenceTimeNameLabel.isHidden = !sender.isSelected
    delegate?.viewController(self, didSwitchBottomSheetViewState: sender.isSelected)
  }
}
