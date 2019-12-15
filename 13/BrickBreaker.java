import java.net.Socket;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ComponentAdapter;
import java.awt.event.ComponentEvent;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URISyntaxException;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.Scanner;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.SwingUtilities;
import javax.swing.Timer;
import javax.swing.*;
import java.io.*;
import java.awt.*;

public class BrickBreaker extends JFrame implements KeyListener {

    private static final int TIME = 1000 / 60;
    private static final int PORT = 60001;
    private final JLabel score = new JLabel("0");
    private int joystick = 0;
    private final String symbols[] = new String[] { " ", "#", "*", "=", "O"};
    private final JTextArea textArea = new JTextArea(20, 42);
    private final String values[][] = new String[42][20];
    private AtomicBoolean needsRepaint = new AtomicBoolean();
    private final Timer timer = new Timer(TIME, this::updateScreen);
    private final Timer autosend;
    private final Socket socket;
    private final BufferedReader reader;
    private final PrintWriter writer;
    private final boolean DEBUG = false;
    private final JButton[] buttons = new JButton[3];

    public BrickBreaker() throws IOException {
        // set up the networking pieces first
        socket = new Socket("localhost", PORT);
        reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        writer = new PrintWriter(socket.getOutputStream(), true);
        
        // now build your GUI
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.add(score);
        textArea.setEditable(false);
        textArea.setFont(new Font(Font.MONOSPACED, Font.PLAIN, 20));
        panel.add(textArea);
        
        // direction buttons
        JPanel subpanel = new JPanel(new FlowLayout());
        for (int i = 0 ; i < 3 ; i++) {
            buttons[i] = new JButton(Integer.toString(i - 1));
            buttons[i].addActionListener(this::send);
            subpanel.add(buttons[i]);
        }
        JButton goButton = new JButton("Go");
        goButton.addActionListener(this::autoSend);
        subpanel.add(goButton);

        JButton stopButton = new JButton("Stop");
        stopButton.addActionListener(this::stopAutoSend);
        subpanel.add(stopButton);

        panel.add(subpanel);
        panel.add(new JLabel("")); // Having some trouble with Java not giving enough space.
        panel.add(new JLabel("")); // Don't feel like actually fixing it.
        add(panel);

        // finally, start the receiver and repainter threads.
        new Thread(this::receive).start();
        timer.setRepeats(true);
        timer.start();

        autosend = new Timer(TIME, evt -> writer.println("0"));
        autosend.setRepeats(true);
    }

    private void send(ActionEvent e) {
        if (DEBUG) System.out.println("Transmit: " + ((JButton)e.getSource()).getText());
        writer.println(((JButton)e.getSource()).getText());
    }

    private void autoSend(ActionEvent e) {
        // Using the "input3.txt" with the floor, we can now send a zero periodically
        // to automatically bounce the ball around.
        autosend.start();
    }

    private void stopAutoSend(ActionEvent e) {
        autosend.stop();
    }

    private void receive() {
        System.out.println(socket);
        System.out.println(reader);

        try {
            while (!socket.isClosed()) {
                int x, y, v;
                try {
                    x = Integer.valueOf(reader.readLine());
                    y = Integer.valueOf(reader.readLine());
                    v = Integer.valueOf(reader.readLine());
                } catch (IOException ex) {
                    System.err.println("Unable to read from socket: " + ex);
                    return;
                }

                if (x == -1 && y == 0) {
                    score.setText(Integer.toString(v));
                } else {
                    synchronized (values) {
                        values[x][y] = symbols[v];
                    }
                }

                if (DEBUG) System.out.println(Arrays.toString(new int[] { x, y, v }));
                needsRepaint.set(true);
            }
        } catch (NumberFormatException ex) {
            timer.stop();
            textArea.setText("Game over");
            for (JButton b : buttons) {
                b.setEnabled(false);
            }
            System.out.println("Game over. Score = " + score.getText());
        } finally {
            try {
                writer.close();
                reader.close();
                socket.close();
            } catch (IOException ex) {
                System.err.println("This is really annoying. " + ex);
            }
        }
    }

    private void updateScreen(ActionEvent e) {
        if (needsRepaint.get() == true) {
            StringBuilder sb = new StringBuilder();
            synchronized(values) {
                for (int y = 0 ; y < 20 ; y++) {
                    for (int x = 0 ; x < 42 ; x++) {
                        sb.append(values[x][y]);
                    }
                    if (y < 19) sb.append("\n");
                }
            }
            textArea.setText(sb.toString());
            if (DEBUG) System.out.println(sb);
            needsRepaint.set(false);
        }
    }

    public static void main (String args[]) {
        SwingUtilities.invokeLater(() -> createAndShowGui());
    }

    private static void createAndShowGui() {
        try {
            final BrickBreaker frame = new BrickBreaker();
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.pack();
            frame.setVisible(true);
            frame.setTitle("Advent of Code 2019 Day 13 Intcode Brick Breaker");
        } catch (IOException ex) {
            System.err.println(ex);
            System.exit(1);
        }
    }

    public void keyPressed(KeyEvent e) {
        System.out.println("hi");
        switch (e.getKeyCode()) {
            case KeyEvent.VK_LEFT:
                this.joystick = -1;
                break;
            case KeyEvent.VK_RIGHT:
                this.joystick = 1;
                break;
            default:
                this.joystick = 0;
                break;
        }
        System.out.println(this.joystick);
    }

    public void keyTyped(KeyEvent e) {
        System.out.println(e.getKeyCode());
    }

    public void keyReleased(KeyEvent e) {
    
        System.out.println(e.getKeyCode());
    }

}