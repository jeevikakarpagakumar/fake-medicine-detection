import pandas as pd
import joblib
import matplotlib.pyplot as plt
import os

from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    roc_curve,
    auc,
    precision_recall_curve
)

#  CREATE PLOTS FOLDER 
PLOT_DIR = "../ml/plots"
os.makedirs(PLOT_DIR, exist_ok=True)

#  LOAD DATA 
train_df = pd.read_csv("../dataset/train_features.csv")
test_df = pd.read_csv("../dataset/test_features.csv")

X_train = train_df.drop("label", axis=1)
y_train = train_df["label"]

X_test = test_df.drop("label", axis=1)
y_test = test_df["label"]

#  MODEL 
model = RandomForestClassifier(n_estimators=100, random_state=42)

#  TRAIN 
model.fit(X_train, y_train)

#  PREDICT 
y_pred = model.predict(X_test)
y_prob = model.predict_proba(X_test)[:, 1]

#  METRICS 
accuracy = accuracy_score(y_test, y_pred)

print("✅ Model trained!")
print(f"Accuracy: {accuracy:.4f}")
print("\nClassification Report:\n")
print(classification_report(y_test, y_pred))

#  CONFUSION MATRIX 
cm = confusion_matrix(y_test, y_pred)

plt.figure()
plt.imshow(cm)
plt.title("Confusion Matrix")
plt.xlabel("Predicted")
plt.ylabel("Actual")

for i in range(len(cm)):
    for j in range(len(cm[0])):
        plt.text(j, i, cm[i][j], ha='center', va='center')

plt.savefig(f"{PLOT_DIR}/confusion_matrix.png")
plt.close()

#  FEATURE IMPORTANCE 
importances = model.feature_importances_
features = X_train.columns

plt.figure()
plt.bar(features, importances)
plt.title("Feature Importance")
plt.xticks(rotation=45)

plt.savefig(f"{PLOT_DIR}/feature_importance.png")
plt.close()

#  ROC CURVE 
fpr, tpr, _ = roc_curve(y_test, y_prob)
roc_auc = auc(fpr, tpr)

plt.figure()
plt.plot(fpr, tpr, label=f"AUC = {roc_auc:.2f}")
plt.xlabel("False Positive Rate")
plt.ylabel("True Positive Rate")
plt.title("ROC Curve")
plt.legend()

plt.savefig(f"{PLOT_DIR}/roc_curve.png")
plt.close()

#  PRECISION-RECALL 
precision, recall, _ = precision_recall_curve(y_test, y_prob)

plt.figure()
plt.plot(recall, precision)
plt.xlabel("Recall")
plt.ylabel("Precision")
plt.title("Precision-Recall Curve")

plt.savefig(f"{PLOT_DIR}/precision_recall_curve.png")
plt.close()

#  SAVE MODEL 
joblib.dump(model, "../models/model.pkl")

print("\n✅ Model saved!")
print(f"📊 Graphs saved in: {PLOT_DIR}")