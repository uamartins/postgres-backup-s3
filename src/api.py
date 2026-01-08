from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

@app.route('/backup', methods=['POST'])
def backup():
    try:
        # Run backup.sh
        result = subprocess.run(['/bin/sh', 'backup.sh'], capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({
                "status": "success", 
                "message": "Backup completed successfully",
                "output": result.stdout
            }), 200
        else:
            return jsonify({
                "status": "error", 
                "message": "Backup failed",
                "output": result.stdout,
                "error": result.stderr
            }), 500
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/restore', methods=['POST'])
def restore():
    try:
        data = request.get_json(silent=True) or {}
        timestamp = data.get('timestamp')
        
        cmd = ['/bin/sh', 'restore.sh']
        if timestamp:
            cmd.append(timestamp)
            
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({
                "status": "success", 
                "message": "Restore completed successfully",
                "output": result.stdout
            }), 200
        else:
            return jsonify({
                "status": "error", 
                "message": "Restore failed",
                "output": result.stdout,
                "error": result.stderr
            }), 500
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy"}), 200

if __name__ == '__main__':
    port = int(os.environ.get('API_PORT', 80))
    app.run(host='0.0.0.0', port=port)
