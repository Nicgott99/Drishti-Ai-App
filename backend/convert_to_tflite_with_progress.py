"""
Professional TFLite Model Conversion with Progress Tracking
Converts PyTorch TB Detection Model to TFLite for offline mobile deployment
"""

import torch
import torch.nn as nn
import os
import sys
import time
import json
from pathlib import Path

# Progress tracking
class ConversionProgress:
    def __init__(self):
        self.total_steps = 10
        self.current_step = 0
        self.start_time = None
        self.step_times = {}
        
    def start(self):
        self.start_time = time.time()
        self.update(0, "Initializing conversion process")
        
    def update(self, step, message, substep=None):
        self.current_step = step
        elapsed = time.time() - self.start_time if self.start_time else 0
        progress_percent = (step / self.total_steps) * 100
        
        progress_data = {
            'step': step,
            'total_steps': self.total_steps,
            'progress': round(progress_percent, 2),
            'message': message,
            'substep': substep,
            'elapsed_time': round(elapsed, 2)
        }
        
        # Output JSON for progress tracking (can be consumed by UI)
        print(f"PROGRESS:{json.dumps(progress_data)}")
        sys.stdout.flush()
        
    def complete(self, success=True, error_msg=None):
        elapsed = time.time() - self.start_time
        result = {
            'success': success,
            'total_time': round(elapsed, 2),
            'error': error_msg
        }
        print(f"COMPLETE:{json.dumps(result)}")
        sys.stdout.flush()


def convert_pytorch_to_tflite():
    """
    Convert PyTorch model to TFLite with comprehensive progress tracking
    """
    progress = ConversionProgress()
    
    try:
        progress.start()
        
        # Step 1: Load PyTorch model
        progress.update(1, "Loading PyTorch model")
        model_path = Path(__file__).parent.parent / "models" / "v3_anti_artifact_512_10pct" / "best_model.pt"
        
        if not model_path.exists():
            raise FileNotFoundError(f"Model not found: {model_path}")
        
        checkpoint = torch.load(str(model_path), map_location='cpu', weights_only=True)
        model_state = checkpoint.get('model_state_dict', checkpoint)
        
        # Step 2: Initialize model architecture
        progress.update(2, "Initializing EfficientNetV2-S architecture")
        from torchvision.models import efficientnet_v2_s
        model = efficientnet_v2_s(weights=None)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, 1)
        model.load_state_dict(model_state)
        model.eval()
        
        # Step 3: Create dummy input
        progress.update(3, "Creating input tensor specification")
        dummy_input = torch.randn(1, 3, 512, 512)
        
        # Step 4: Export to ONNX
        progress.update(4, "Exporting PyTorch model to ONNX format")
        onnx_path = Path(__file__).parent / "tb_detector_temp.onnx"
        torch.onnx.export(
            model,
            dummy_input,
            str(onnx_path),
            export_params=True,
            opset_version=13,
            do_constant_folding=True,
            input_names=['input'],
            output_names=['output'],
            dynamic_axes={
                'input': {0: 'batch_size'},
                'output': {0: 'batch_size'}
            }
        )
        
        # Step 5: Load ONNX model
        progress.update(5, "Loading ONNX model for conversion")
        import onnx
        onnx_model = onnx.load(str(onnx_path))
        onnx.checker.check_model(onnx_model)
        
        # Step 6: Convert ONNX to TensorFlow
        progress.update(6, "Converting ONNX to TensorFlow format", "This may take several minutes...")
        from onnx_tf.backend import prepare
        tf_rep = prepare(onnx_model)
        
        # Step 7: Save TensorFlow model
        progress.update(7, "Saving TensorFlow SavedModel")
        tf_model_path = Path(__file__).parent / "tb_detector_tf"
        tf_rep.export_graph(str(tf_model_path))
        
        # Step 8: Convert to TFLite
        progress.update(8, "Converting to TensorFlow Lite format")
        import tensorflow as tf
        
        converter = tf.lite.TFLiteConverter.from_saved_model(str(tf_model_path))
        
        # Optimization: Dynamic range quantization for smaller model size
        progress.update(8, "Converting to TensorFlow Lite format", "Applying optimizations...")
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        
        tflite_model = converter.convert()
        
        # Step 9: Save TFLite model
        progress.update(9, "Saving optimized TFLite model")
        tflite_path = Path(__file__).parent.parent / "assets" / "models" / "tb_detector.tflite"
        tflite_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(tflite_path, 'wb') as f:
            f.write(tflite_model)
        
        # Step 10: Validate model
        progress.update(10, "Validating TFLite model")
        interpreter = tf.lite.Interpreter(model_path=str(tflite_path))
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        # Test inference
        test_input = dummy_input.numpy()
        interpreter.set_tensor(input_details[0]['index'], test_input)
        interpreter.invoke()
        tflite_output = interpreter.get_tensor(output_details[0]['index'])
        
        # Clean up temporary files
        if onnx_path.exists():
            onnx_path.unlink()
        import shutil
        if tf_model_path.exists():
            shutil.rmtree(tf_model_path)
        
        # Get model size
        model_size_mb = tflite_path.stat().st_size / (1024 * 1024)
        
        progress.complete(success=True)
        
        print(f"\n{'='*80}")
        print("CONVERSION SUCCESSFUL!")
        print(f"{'='*80}")
        print(f"TFLite Model: {tflite_path}")
        print(f"Model Size: {model_size_mb:.2f} MB")
        print(f"Input Shape: {input_details[0]['shape']}")
        print(f"Output Shape: {output_details[0]['shape']}")
        print(f"{'='*80}\n")
        
        return True
        
    except ImportError as e:
        error_msg = f"Missing dependency: {str(e)}"
        progress.complete(success=False, error_msg=error_msg)
        print(f"\nERROR: {error_msg}")
        print("\nInstall required packages:")
        print("pip install onnx onnx-tf tensorflow")
        return False
        
    except Exception as e:
        error_msg = str(e)
        progress.complete(success=False, error_msg=error_msg)
        print(f"\nERROR: {error_msg}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("="*80)
    print("DRISHTI AI - TFLITE MODEL CONVERSION")
    print("="*80)
    print("Converting PyTorch TB Detection Model to TFLite")
    print("This process will take several minutes...")
    print("="*80)
    print()
    
    success = convert_pytorch_to_tflite()
    sys.exit(0 if success else 1)
