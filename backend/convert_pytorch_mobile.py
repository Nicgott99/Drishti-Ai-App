"""
Simplified TFLite Conversion using PyTorch Mobile (TorchScript)
This approach avoids ONNX/TF dependency issues
"""

import torch
import torch.nn as nn
from pathlib import Path
import json
import time
import sys


class ConversionProgress:
    """Track and report conversion progress"""
    
    def __init__(self, total_steps=6):
        self.total_steps = total_steps
        self.current_step = 0
        self.start_time = None
        
    def start(self):
        self.start_time = time.time()
        self.update(0, "Initializing conversion")
        
    def update(self, step, message, substep=None):
        self.current_step = step
        elapsed = time.time() - self.start_time if self.start_time else 0
        progress = (step / self.total_steps) * 100
        
        data = {
            'step': step,
            'total': self.total_steps,
            'progress': round(progress, 2),
            'message': message,
            'substep': substep,
            'elapsed': round(elapsed, 2)
        }
        
        print(f"PROGRESS:{json.dumps(data)}")
        sys.stdout.flush()
        
    def complete(self, success=True, error=None):
        elapsed = time.time() - self.start_time
        result = {
            'success': success,
            'time': round(elapsed, 2),
            'error': error
        }
        print(f"COMPLETE:{json.dumps(result)}")
        sys.stdout.flush()


def convert_to_torchscript():
    """
    Convert PyTorch model to TorchScript (mobile-optimized)
    This is simpler and avoids TensorFlow dependencies
    """
    progress = ConversionProgress(total_steps=6)
    
    try:
        progress.start()
        
        # Step 1: Load model
        progress.update(1, "Loading PyTorch model")
        model_path = Path(r"H:\Project Drishti A Multi-Modal AI Platform to Close the TB Diagnostic Gap in Bangladesh\models\v3_anti_artifact_512_10pct\best_model.pt")
        
        if not model_path.exists():
            raise FileNotFoundError(f"Model not found: {model_path}")
        
        checkpoint = torch.load(
            str(model_path),
            map_location='cpu',
            weights_only=False  # Model file trusted
        )
        state_dict = checkpoint.get('model_state_dict', checkpoint)
        
        # Step 2: Build architecture
        progress.update(2, "Building EfficientNetV2-S architecture")
        from torchvision.models import (
            efficientnet_v2_s,
            EfficientNet_V2_S_Weights
        )
        
        # Use TBClassifier wrapper (same as server.py)
        class TBClassifier(nn.Module):
            def __init__(self, pretrained=False, dropout=0.3):
                super(TBClassifier, self).__init__()
                self.backbone = efficientnet_v2_s(
                    weights=(EfficientNet_V2_S_Weights.DEFAULT
                             if pretrained else None)
                )
                num_features = self.backbone.classifier[1].in_features
                self.backbone.classifier = nn.Sequential(
                    nn.Dropout(p=dropout),
                    nn.Linear(num_features, 1),
                    nn.Sigmoid()
                )
            
            def forward(self, x):
                return self.backbone(x)
        
        model = TBClassifier(pretrained=False, dropout=0.3)
        model.load_state_dict(state_dict)
        model.eval()
        
        # Step 3: Optimize for mobile
        progress.update(3, "Optimizing model for mobile deployment")
        from torch.utils.mobile_optimizer import optimize_for_mobile
        
        # Create example input
        example = torch.randn(1, 3, 512, 512)
        
        # Step 4: Trace model
        progress.update(4, "Tracing model with TorchScript")
        traced_model = torch.jit.trace(model, example)
        
        # Step 5: Mobile optimization
        progress.update(5, "Applying mobile optimizations")
        optimized_model = optimize_for_mobile(traced_model)
        
        # Step 6: Save
        progress.update(6, "Saving optimized mobile model")
        base_path = Path(__file__).parent.parent
        output_dir = base_path / "assets" / "models"
        output_dir.mkdir(parents=True, exist_ok=True)
        
        output_path = output_dir / "tb_detector_mobile.ptl"
        optimized_model._save_for_lite_interpreter(str(output_path))
        
        # Get size
        size_mb = output_path.stat().st_size / (1024 * 1024)
        
        progress.complete(success=True)
        
        print(f"\n{'='*70}")
        print("CONVERSION SUCCESSFUL!")
        print(f"{'='*70}")
        print(f"Output: {output_path}")
        print(f"Size: {size_mb:.2f} MB")
        print(f"Format: PyTorch Lite (ptl)")
        print(f"Input: (1, 3, 512, 512)")
        print(f"Output: (1, 1) - TB probability")
        print(f"{'='*70}\n")
        
        return True
        
    except Exception as e:
        error_msg = str(e)
        progress.complete(success=False, error=error_msg)
        print(f"\nERROR: {error_msg}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("="*70)
    print("DRISHTI AI - PYTORCH MOBILE CONVERSION")
    print("="*70)
    print("Converting to PyTorch Lite format for mobile")
    print("This avoids TensorFlow/ONNX dependencies")
    print("="*70)
    print()
    
    success = convert_to_torchscript()
    sys.exit(0 if success else 1)
