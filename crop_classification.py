from tensorflow.keras.models import Model, load_model
from tensorflow.keras.layers import Input, Conv2D, MaxPooling2D, Flatten, Dense, BatchNormalization, concatenate, Reshape
from tensorflow.keras.layers import LayerNormalization, MultiHeadAttention, GlobalAveragePooling1D, Dropout, LSTM, TimeDistributed
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau, CSVLogger, TensorBoard
from sklearn.preprocessing import LabelEncoder
import os
import json
from tensorflow.keras.utils import plot_model

class CropClassificationModel:
    def __init__(self, input_shape, num_classes, model_type='cnn_hybrid', params=None):
        """
        Initialize the model.
        :param input_shape: Tuple (T, H, W, C) representing the input sequence dimensions.
        :param num_classes: Number of output classes.
        :param model_type: 'cnn_hybrid', 'cnn_transformer', or 'rnn'.
        :param params: Dictionary of parameters for the model (e.g., number of filters, heads, etc.).
        """
        if not isinstance(input_shape, tuple) or len(input_shape) not in [3, 4]:
            raise ValueError("input_shape must be a tuple (H, W, C) or (T, H, W, C).")
        if not isinstance(num_classes, int) or num_classes <= 0:
            raise ValueError("num_classes must be a positive integer.")
        if model_type not in ['cnn_hybrid', 'cnn_transformer', 'rnn']:
            raise ValueError("model_type must be 'cnn_hybrid', 'cnn_transformer', or 'rnn'.")

        self.input_shape = input_shape
        self.num_classes = num_classes
        self.model_type = model_type
        self.params = params if params is not None else {}
        self.model = None
        self.optimizer = None
        self.loss = None
        self.label_encoder = None

    def _build_cnn_hybrid(self):
        """Build the CNN Hybrid model."""
        input_layer = Input(shape=self.input_shape)

        # Bloco espectral
        spectral = Conv2D(32, (1, 1), activation='relu')(input_layer)
        spectral = BatchNormalization()(spectral)
        spectral = Dropout(0.3)(spectral)

        # Bloco espacial
        spatial = Conv2D(64, (3, 3), activation='relu', padding='same')(input_layer)
        spatial = MaxPooling2D((2, 2))(spatial)
        spatial = Dropout(0.3)(spatial)

        # Fusão
        fusion = concatenate([spectral, spatial])
        fusion = Conv2D(128, (3, 3), activation='relu')(fusion)
        fusion = MaxPooling2D((2, 2))(fusion)
        fusion = Dropout(0.3)(fusion)

        # Camada densa final
        flattened = Flatten()(fusion)
        dense = Dense(128, activation='relu')(flattened)
        dense = Dropout(0.3)(dense)
        output_layer = Dense(self.num_classes, activation='softmax')(dense)

        self.model = Model(inputs=input_layer, outputs=output_layer)

    def _build_cnn_transformer(self):
        """Build the CNN-Transformer Hybrid model."""
        input_layer = Input(shape=self.input_shape)

        # Bloco convolucional inicial
        conv = Conv2D(64, (3, 3), activation='relu', padding='same')(input_layer)
        conv = Dropout(0.3)(conv)
        conv = Conv2D(128, (3, 3), activation='relu', padding='same')(conv)
        conv = Flatten()(conv)

        # Transformação para sequência
        patches = Reshape((-1, self.input_shape[-1]))(conv)  # Transformar para sequência (patches, bandas)
        patches = LayerNormalization()(patches)

        # Transformer espectral
        attention = MultiHeadAttention(num_heads=self.params.get('num_heads', 4), 
                                        key_dim=self.input_shape[-1])(patches, patches)
        attention = LayerNormalization()(attention)
        attention = GlobalAveragePooling1D()(attention)

        # Classificador final
        dense = Dense(128, activation='relu')(attention)
        dense = Dropout(0.3)(dense)
        output_layer = Dense(self.num_classes, activation='softmax')(dense)

        self.model = Model(inputs=input_layer, outputs=output_layer)

    def _build_rnn(self):
        """Build the RNN model for temporal sequence data."""
        input_layer = Input(shape=self.input_shape)

        # TimeDistributed CNN layers for feature extraction
        cnn = TimeDistributed(Conv2D(64, (3, 3), activation='relu', padding='same'))(input_layer)
        cnn = TimeDistributed(MaxPooling2D((2, 2)))(cnn)
        cnn = TimeDistributed(Conv2D(128, (3, 3), activation='relu', padding='same'))(cnn)
        cnn = TimeDistributed(MaxPooling2D((2, 2)))(cnn)
        cnn = TimeDistributed(Flatten())(cnn)

        # LSTM layer for temporal learning
        lstm = LSTM(128, return_sequences=False, dropout=0.3, recurrent_dropout=0.3)(cnn)

        # Fully connected layers
        dense = Dense(128, activation='relu')(lstm)
        dense = Dropout(0.3)(dense)
        output_layer = Dense(self.num_classes, activation='softmax')(dense)

        self.model = Model(inputs=input_layer, outputs=output_layer)

    def _build_model_rrn(self):
        """
        Build the model based on the selected type.
        """
        if self.model_type == 'cnn_hybrid':
            self._build_cnn_hybrid()
        elif self.model_type == 'cnn_transformer':
            self._build_cnn_transformer()
        elif self.model_type == 'rnn':
            self._build_rnn()
        else:
            raise ValueError(f"Unsupported model type: {self.model_type}")

    def compile_model(self, optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy']):
        """
        Compile the model.
        :param optimizer: Optimizer to use.
        :param loss: Loss function to use.
        :param metrics: Metrics to evaluate during training.
        """
        if self.model is None:
            self._build_model_rrn()
        self._set_optimizer(optimizer)
        self._set_loss(loss)
        self.model.compile(optimizer=self.optimizer, loss=self.loss, metrics=metrics)

    def _set_optimizer(self, optimizer):
        """Set the optimizer."""
        self.optimizer = optimizer

    def _set_loss(self, loss):
        """Set the loss function."""
        self.loss = loss

    def _set_label_encoder(self, y):
        """
        Set the label encoder based on the labels.
        :param y: Labels to encode.
        """
        self.label_encoder = LabelEncoder()
        return self.label_encoder.fit_transform(y)

    def set_callbacks(self, early_stop_monitor='val_loss', early_stop_patience=10, log_dir='./logs', reduce_lr_monitor='val_loss', reduce_lr_factor=0.5, reduce_lr_patience=5, log_file='training.log'):
        """
        Set up the callbacks for training.
        :param early_stop_monitor: Metric to monitor for early stopping.
        :param early_stop_patience: Number of epochs with no improvement for early stopping.
        :param log_dir: Directory for TensorBoard logs.
        :param reduce_lr_monitor: Metric to monitor for reducing learning rate.
        :param reduce_lr_factor: Factor by which the learning rate will be reduced.
        :param reduce_lr_patience: Number of epochs with no improvement for reducing learning rate.
        :param log_file: Path to save the training log.
        :return: List of configured callbacks.
        """
        early_stopping = EarlyStopping(monitor=early_stop_monitor, patience=early_stop_patience, restore_best_weights=True)
        checkpoint = ModelCheckpoint(filepath='checkpoint-epoch{epoch:02d}-val_loss{val_loss:.2f}.h5', monitor='val_loss', save_best_only=True)
        reduce_lr = ReduceLROnPlateau(monitor=reduce_lr_monitor, factor=reduce_lr_factor, patience=reduce_lr_patience)
        csv_logger = CSVLogger(log_file)
        tensorboard = TensorBoard(log_dir=log_dir)

        return [early_stopping, checkpoint, reduce_lr, csv_logger, tensorboard]

    def train(self, x_train, y_train, x_val, y_val, epochs=50, batch_size=32, callbacks=None):
        """
        Train the model.
        :param x_train: Training data.
        :param y_train: Training labels.
        :param x_val: Validation data.
        :param y_val: Validation labels.
        :param epochs: Number of epochs.
        :param batch_size: Batch size.
        :param callbacks: List of callbacks.
        :return: Training history.
        """
        if self.model is None:
            self._build_model_rrn()
        try:
            history = self.model.fit(x_train, y_train, validation_data=(x_val, y_val), 
                                     epochs=epochs, batch_size=batch_size, callbacks=callbacks)
            return history
        except Exception as e:
            with open('error.log', 'a') as f:
                f.write(f"Training error: {str(e)}\n")
            raise

    def predict(self, x):
        """
        Predict the labels for the given input.
        :param x: Input data.
        :return: Predicted labels.
        """
        if self.model is None:
            raise ValueError("Model is not built or loaded. Build or load a model before predicting.")
        return self.model.predict(x)

    def save_model(self, filepath):
        """
        Save the model to the specified file.
        :param filepath: Path to save the model.
        """
        if self.model is None:
            raise ValueError("Model is not built or trained. Build or train a model before saving.")
        self.model.save(filepath)

    def load_model(self, filepath):
        """
        Load a saved model from the specified file.
        :param filepath: Path to the saved model file.
        """
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"The specified file does not exist: {filepath}")
        self.model = load_model(filepath)

    def save_config(self, filepath):
        """
        Save the model configuration and parameters to a file.
        :param filepath: Path to save the configuration.
        """
        config = {
            'input_shape': self.input_shape,
            'num_classes': self.num_classes,
            'model_type': self.model_type,
            'params': self.params
        }
        with open(filepath, 'w') as f:
            json.dump(config, f, indent=4)

    def load_config(self, filepath):
        """
        Load the model configuration and parameters from a file.
        :param filepath: Path to the configuration file.
        """
        if not os.path.exists(filepath):
            raise FileNotFoundError(f"The specified file does not exist: {filepath}")
        with open(filepath, 'r') as f:
            config = json.load(f)
        self.input_shape = tuple(config['input_shape'])
        self.num_classes = config['num_classes']
        self.model_type = config['model_type']
        self.params = config['params']

    def plot_model_architecture(self, filepath='model.png'):
        """
        Save a visualization of the model architecture to a file.
        :param filepath: Path to save the model architecture visualization.
        """
        if self.model is None:
            self._build_model_rrn()
        plot_model(self.model, to_file=filepath, show_shapes=True, show_layer_names=True)

    def get_model(self):
        """Return the built model."""
        if self.model is None:
            self._build_model_rrn()
        return self.model
