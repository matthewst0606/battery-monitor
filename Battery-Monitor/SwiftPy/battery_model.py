
import torch
import torch.optim as optim
import torch.nn as nn

class BatteryModel:
    # --- initialize a sequential model & optimizer ---
    def __init__(self):
        torch.manual_seed(0)
        self.device = 'cpu'
        self.loss_fc = nn.L1Loss()
        self.model = nn.Sequential(
            nn.Linear(24, 128),
            nn.ReLU(),
            nn.Linear(128, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, 1),
        ).to(self.device)

        # -------- create an optimizer --------
        self.optimizer = optim.Adam(
            self.model.parameters(),
            lr=0.001
        )
        
    # -------- running the model --------
    def run_model(self, x_train, y_train):
        for epoch in range(1000): 
            self.model.train()
            self.optimizer.zero_grad()

            predicted_y = self.model(x_train)
            loss = self.loss_fc(predicted_y, y_train)

            loss.backward()
            self.optimizer.step()



    # --- evaluate model results on validation data ---
    def evaluate_model(self, x_val, y_val, y_scaler):
        self.model.eval()
        with torch.no_grad():
            # numpy array as tensor
            x_val = torch.as_tensor(x_val).float().to(self.device)
            y_val = torch.as_tensor(y_val).float().to(self.device)

            # calculate validation loss
            x_prediction = self.model(x_val)
            val_loss = self.loss_fc(x_prediction, y_val)

            # get actual values from the scaled values
            predicted = x_prediction.detach().cpu().numpy()
            actual = y_val.detach().cpu().numpy()

            actual_y = y_scaler.inverse_transform(actual)
            predicted_y = y_scaler.inverse_transform(predicted)
        return actual_y, predicted_y, val_loss



    def save(self, path):
        torch.save(self.model.state_dict(), path)

    def load(self, path):
        self.model.load_state_dict(torch.load(path, map_location=self.device))
        self.model.eval()
    


    
